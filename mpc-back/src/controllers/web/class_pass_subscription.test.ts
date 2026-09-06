/**
 * Integration test for the recurring half of the class pass: buying one as a
 * subscription, renewals extending it, and the member-facing auto-renew switch.
 * Run: npx ts-node src/controllers/web/class_pass_subscription.test.ts
 *
 * Stripe itself is stubbed at the client boundary — what matters here is the
 * shape of the session we ask for and what we do with what comes back.
 * See docs/specs/class-pass.md D17, D18, D19.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import Customer from '../../models/Customer';
import Session from '../../models/Session';
import {
  LEGACY_QUARTERLY_PASS_PRODUCT,
  MONTHLY_PASS_PRODUCT,
  seedClassPassProduct,
} from '../../scripts/seed_class_passes';
import { createSession } from '../../services/auth';
import { applyRenewalInvoice } from '../../services/class_pass';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const stripe = require('../../config/stripe').default;
// eslint-disable-next-line @typescript-eslint/no-var-requires
const GroupClassController = require('./group_class_controller').default;

const ctrl = new GroupClassController();

// ---- Stripe stub: record what we asked for, hand back a plausible answer ----
let sessionArgs: any[] = [];
let subscriptionUpdates: Array<{ id: string; params: any }> = [];
let canceled: string[] = [];
let subscriptionState: Record<string, any> = {};

stripe.checkout.sessions.create = async (params: any) => {
  sessionArgs.push(params);
  return { id: `cs_test_${sessionArgs.length}`, url: 'https://checkout.stripe.test/x' };
};
stripe.subscriptions.update = async (id: string, params: any) => {
  subscriptionUpdates.push({ id, params });
  subscriptionState[id] = { ...(subscriptionState[id] || {}), ...params };
  if (subscriptionState[id]?.status === 'canceled') {
    throw Object.assign(new Error('No such subscription'), { code: 'resource_missing' });
  }
  return { id, ...subscriptionState[id] };
};
stripe.subscriptions.cancel = async (id: string) => {
  canceled.push(id);
  subscriptionState[id] = { ...(subscriptionState[id] || {}), status: 'canceled' };
  return { id, status: 'canceled' };
};

function resetStripeStub() {
  sessionArgs = [];
  subscriptionUpdates = [];
  canceled = [];
  subscriptionState = {};
}

function mockRes() {
  const r: any = { statusCode: 200, body: null, headers: {} as Record<string, string> };
  r.status = (c: number) => ((r.statusCode = c), r);
  r.json = (b: any) => ((r.body = b), r);
  r.cookie = () => r;
  return r;
}

/** A request carrying a valid session cookie for this customer. */
async function signedInAs(email: string, body: Record<string, unknown> = {}) {
  const customer = await Customer.findOne({ email });
  const raw = await createSession(customer!);
  return { body, headers: { cookie: `mpc_session=${raw}` } } as any;
}

let passed = 0;
function check(name: string, cond: boolean) {
  assert.ok(cond, `FAIL: ${name}`);
  console.log('  ✓', name);
  passed++;
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  await ClassPass.syncIndexes();
  try {
    // ---- D17: the buyer picks how the sale is billed ----

    // 1. Recurring asks Stripe for a subscription
    {
      await ClassPass.deleteMany({});
      await ClassPassProduct.deleteMany({});
      resetStripeStub();
      const product = await seedClassPassProduct(MONTHLY_PASS_PRODUCT);

      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(product._id),
            email: 'ruth@example.com',
            firstName: 'Ruth',
            autoRenew: true,
          },
        } as any,
        res
      );

      check('a recurring purchase reaches checkout', res.statusCode === 200);
      const args = sessionArgs[0];
      check('the session is a subscription', args.mode === 'subscription');
      check('it recurs monthly for a 1-month product',
        args.line_items[0].price_data.recurring?.interval === 'month' &&
        args.line_items[0].price_data.recurring?.interval_count === 1);
      check('the price is the product price', args.line_items[0].price_data.unit_amount === 9000);
      check('the subscription carries our metadata, since renewal invoices do not carry the session',
        args.subscription_data?.metadata?.kind === 'class_pass' &&
        args.subscription_data?.metadata?.email === 'ruth@example.com' &&
        args.subscription_data?.metadata?.productId === String(product._id));
    }

    // 2. A 3-month product sold recurring bills quarterly, not monthly
    {
      resetStripeStub();
      const quarterly = await seedClassPassProduct({
        ...LEGACY_QUARTERLY_PASS_PRODUCT,
        allowSubscription: true,
      });

      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(quarterly._id),
            email: 'quarterly@example.com',
            firstName: 'Q',
            autoRenew: true,
          },
        } as any,
        res
      );
      check('the billing interval is derived from the product term',
        sessionArgs[0].line_items[0].price_data.recurring.interval_count === 3);
      await ClassPassProduct.deleteMany({ name: LEGACY_QUARTERLY_PASS_PRODUCT.name });
    }

    // 3. The one-off path is untouched
    {
      resetStripeStub();
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });

      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(product!._id),
            email: 'once@example.com',
            firstName: 'Once',
            autoRenew: false,
          },
        } as any,
        res
      );
      const args = sessionArgs[0];
      check('a one-off purchase is a payment, not a subscription', args.mode === 'payment');
      check('a one-off line item does not recur', !args.line_items[0].price_data.recurring);
      check('a one-off session carries no subscription data', !args.subscription_data);
    }

    // 4. Omitting the flag buys once — the API never assumes recurring
    {
      resetStripeStub();
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(product!._id),
            email: 'silent@example.com',
            firstName: 'S',
          },
        } as any,
        res
      );
      check('a request that says nothing about renewal is a one-off',
        sessionArgs[0].mode === 'payment');
    }

    // 5. A product that may not recur refuses to, before Stripe is called
    {
      resetStripeStub();
      const oneOffOnly = await seedClassPassProduct({
        name: 'Drop-in Block',
        months: 1,
        priceCents: 5000,
        currency: 'eur',
      });

      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(oneOffOnly._id),
            email: 'nope@example.com',
            firstName: 'N',
            autoRenew: true,
          },
        } as any,
        res
      );
      check('asking to recur on a product that cannot is a 400', res.statusCode === 400);
      check('and no Stripe session was created', sessionArgs.length === 0);
      await ClassPassProduct.deleteMany({ name: 'Drop-in Block' });
    }

    // 6. The one-active-pass rule survives the new mode (D7)
    {
      resetStripeStub();
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'held@example.com',
        firstName: 'Held',
        stripeSessionId: 'cs_held',
      });

      const res = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(product!._id),
            email: 'held@example.com',
            firstName: 'Held',
            autoRenew: true,
          },
        } as any,
        res
      );
      check('a holder cannot subscribe on top of a live pass', res.statusCode === 409);
      check('and no Stripe session was created for it', sessionArgs.length === 0);
    }

    // 7. The subscription id reaches the pass
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });

      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'ruth@example.com',
        firstName: 'Ruth',
        stripeSessionId: 'cs_sub_1',
        stripeSubscriptionId: 'sub_123',
      });

      const pass = await ClassPass.findOne({ email: 'ruth@example.com' });
      check('a subscription pass remembers its subscription', pass!.stripeSubscriptionId === 'sub_123');
      check('a subscription pass renews by default', pass!.autoRenew === true);
      check('a subscription pass is active', pass!.subscriptionStatus === 'active');
    }

    // 8. A one-off pass carries no renewal state at all
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'once@example.com',
        firstName: 'Once',
        stripeSessionId: 'cs_once_1',
      });

      const pass = await ClassPass.findOne({ email: 'once@example.com' });
      check('a one-off pass has no subscription', !pass!.stripeSubscriptionId);
      check('a one-off pass does not renew', pass!.autoRenew === false);
    }

    // ---- D18: a renewal extends the pass it belongs to ----

    async function subscriptionPass(overrides: Record<string, unknown> = {}) {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'ruth@example.com',
        firstName: 'Ruth',
        stripeSessionId: `cs_${Math.random()}`,
        stripeSubscriptionId: 'sub_renew',
      });
      return ClassPass.findOneAndUpdate(
        { stripeSubscriptionId: 'sub_renew' },
        { $set: { validFromDate: '2026-09-01', validUntilDate: '2026-10-01', ...overrides } },
        { new: true }
      );
    }

    // 9. A paid invoice pushes the end date out by the product's term
    {
      await subscriptionPass();
      const result = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew',
        invoiceId: 'in_1',
        today: '2026-09-28',
      });

      check('the renewal reports it extended the pass', result!.extended === true);
      check('the term runs a month past where it ended, not a month from payment day',
        result!.pass.validUntilDate === '2026-11-01');
      check('the pass is not duplicated', (await ClassPass.countDocuments({})) === 1);
      check('the invoice is recorded as spent',
        result!.pass.consumedInvoiceIds.includes('in_1'));
    }

    // 10. A redelivered invoice buys nothing
    {
      await subscriptionPass();
      await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew',
        invoiceId: 'in_replay',
        today: '2026-09-28',
      });
      const again = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew',
        invoiceId: 'in_replay',
        today: '2026-09-28',
      });

      check('replaying an invoice extends nothing', again!.extended === false);
      check('and the end date is unmoved', again!.pass.validUntilDate === '2026-11-01');
    }

    // 11. Simultaneous redelivery is the same guarantee, under a race
    {
      await subscriptionPass();
      const results = await Promise.all(
        Array.from({ length: 5 }, () =>
          applyRenewalInvoice({
            stripeSubscriptionId: 'sub_renew',
            invoiceId: 'in_race',
            today: '2026-09-28',
          })
        )
      );
      check('exactly one of five simultaneous deliveries extends the pass',
        results.filter((r) => r!.extended).length === 1);
      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_renew' });
      check('the pass gained exactly one month', pass!.validUntilDate === '2026-11-01');
    }

    // 12. Two real months are two extensions
    {
      await subscriptionPass();
      await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew', invoiceId: 'in_a', today: '2026-09-28',
      });
      const second = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew', invoiceId: 'in_b', today: '2026-10-28',
      });
      check('a second invoice extends again', second!.pass.validUntilDate === '2026-12-01');
      check('both invoices are recorded', second!.pass.consumedInvoiceIds.length === 2);
    }

    // 13. A lapsed pass comes back from today, not from its stale end date
    {
      await subscriptionPass({ validUntilDate: '2026-08-01' });
      const result = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew', invoiceId: 'in_late', today: '2026-09-28',
      });
      check('a lapsed pass is revived from today', result!.pass.validUntilDate === '2026-10-28');
    }

    // 14. A revoked pass is not extended, whatever Stripe says (D9)
    {
      await subscriptionPass({ revoked: true });
      const result = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_renew', invoiceId: 'in_revoked', today: '2026-09-28',
      });
      check('a revoked pass is not extended', result!.extended === false);
      check('and its end date is untouched', result!.pass.validUntilDate === '2026-10-01');
    }

    // 15. An invoice for something we do not know about is not an error
    {
      const result = await applyRenewalInvoice({
        stripeSubscriptionId: 'sub_unknown', invoiceId: 'in_x', today: '2026-09-28',
      });
      check('an unknown subscription yields nothing, and does not throw', result === null);
    }

    // ---- D19: the member decides whether it keeps renewing ----

    async function memberWithSubscriptionPass() {
      await ClassPass.deleteMany({});
      await Session.deleteMany({});
      await Customer.deleteMany({});
      resetStripeStub();
      subscriptionState['sub_switch'] = { status: 'active', cancel_at_period_end: false };

      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'ruth@example.com',
        firstName: 'Ruth',
        stripeSessionId: `cs_${Math.random()}`,
        stripeSubscriptionId: 'sub_switch',
      });
      // The customer row comes from activation itself — the pass email calls
      // findOrCreateCustomer to mint the sign-in link (D16).
    }

    // 16. Turning it off stops the next charge and keeps the paid term
    {
      await memberWithSubscriptionPass();
      const before = await ClassPass.findOne({ email: 'ruth@example.com' });

      const res = mockRes();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: false }), res);

      check('turning renewal off succeeds', res.statusCode === 200);
      check('Stripe is told to stop at the end of the period, not now',
        subscriptionUpdates[0]?.id === 'sub_switch' &&
        subscriptionUpdates[0]?.params.cancel_at_period_end === true);
      check('the subscription is not cancelled outright', canceled.length === 0);

      const after = await ClassPass.findOne({ email: 'ruth@example.com' });
      check('our copy says it no longer renews', after!.autoRenew === false);
      check('the pass is marked as winding down', after!.subscriptionStatus === 'canceling');
      check('the term already paid for is untouched',
        after!.validUntilDate === before!.validUntilDate);
      check('the response tells the member where they stand',
        res.body.autoRenew === false && res.body.validUntilDate === before!.validUntilDate);
    }

    // 17. And back on again, while the subscription is still alive
    {
      await memberWithSubscriptionPass();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: false }), mockRes());

      const res = mockRes();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: true }), res);

      check('turning renewal back on succeeds', res.statusCode === 200);
      check('Stripe is told to keep going',
        subscriptionUpdates[1]?.params.cancel_at_period_end === false);
      const after = await ClassPass.findOne({ email: 'ruth@example.com' });
      check('our copy says it renews again', after!.autoRenew === true);
      check('and the pass is active again', after!.subscriptionStatus === 'active');
    }

    // 18. Once Stripe has really ended it, the answer is to buy again
    {
      await memberWithSubscriptionPass();
      await ClassPass.updateOne(
        { stripeSubscriptionId: 'sub_switch' },
        { $set: { autoRenew: false, subscriptionStatus: 'canceled' } }
      );

      const res = mockRes();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: true }), res);
      check('restarting a dead subscription is refused', res.statusCode === 409);
      check('and Stripe is not asked to do it', subscriptionUpdates.length === 0);
    }

    // 19. Identity comes from the session, never the body (D2)
    {
      await memberWithSubscriptionPass();

      const anon = mockRes();
      await ctrl.setAutoRenew({ body: { autoRenew: false }, headers: {} } as any, anon);
      check('an anonymous caller cannot stop anybody renewing', anon.statusCode === 401);
      check('and Stripe is not touched', subscriptionUpdates.length === 0);
    }

    // 20. Nothing to switch off
    {
      await memberWithSubscriptionPass();
      await ClassPass.updateMany({}, { $unset: { stripeSubscriptionId: '' } });

      const res = mockRes();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: false }), res);
      check('a one-off pass has no renewal to stop', res.statusCode === 409);
    }

    // 21. A missing or non-boolean flag is a bad request, not a guess
    {
      await memberWithSubscriptionPass();
      const res = mockRes();
      await ctrl.setAutoRenew(await signedInAs('ruth@example.com', { autoRenew: 'nope' }), res);
      check('a non-boolean autoRenew is a 400', res.statusCode === 400);
    }

    // 22. A change made in the Stripe dashboard is mirrored, not contradicted
    {
      await memberWithSubscriptionPass();
      await ctrl.syncSubscriptionState({
        stripeSubscriptionId: 'sub_switch',
        status: 'active',
        cancelAtPeriodEnd: true,
        currentPeriodEndDate: '2026-10-01',
      });

      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_switch' });
      check('a dashboard cancellation shows as not renewing', pass!.autoRenew === false);
      check('and as winding down', pass!.subscriptionStatus === 'canceling');
      // A charge that will never arrive must not be advertised as due. What
      // the member needs to see now is when they lose access, which is the
      // pass's own end date.
      check('a subscription winding down advertises no next charge', !pass!.nextChargeDate);
    }

    {
      await memberWithSubscriptionPass();
      await ctrl.syncSubscriptionState({
        stripeSubscriptionId: 'sub_switch',
        status: 'active',
        cancelAtPeriodEnd: false,
        currentPeriodEndDate: '2026-10-01',
      });

      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_switch' });
      check('a live subscription records when the next charge falls',
        pass!.nextChargeDate === '2026-10-01');
      check('and shows as renewing', pass!.autoRenew === true);
    }

    {
      await memberWithSubscriptionPass();
      await ctrl.syncSubscriptionState({
        stripeSubscriptionId: 'sub_switch',
        status: 'canceled',
        cancelAtPeriodEnd: true,
      });

      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_switch' });
      check('an ended subscription is recorded as cancelled', pass!.subscriptionStatus === 'canceled');
      check('and no next charge is shown', !pass!.nextChargeDate);
      check('a cancelled subscription does not revoke the pass', pass!.revoked === false);
    }

    {
      await ctrl.syncSubscriptionState({
        stripeSubscriptionId: 'sub_nobody',
        status: 'canceled',
        cancelAtPeriodEnd: true,
      });
      check('syncing a subscription we do not hold is a no-op, not a throw', true);
    }

    // 23. The member can see the state on their pass
    {
      await memberWithSubscriptionPass();
      await ClassPass.updateOne(
        { stripeSubscriptionId: 'sub_switch' },
        { $set: { nextChargeDate: '2026-10-04' } }
      );

      const res = mockRes();
      await ctrl.getMyPass(await signedInAs('ruth@example.com'), res);
      check('the pass reports that it recurs', res.body.pass.recurring === true);
      check('the pass reports that it renews', res.body.pass.autoRenew === true);
      check('the pass reports when the next charge falls',
        res.body.pass.nextChargeDate === '2026-10-04');
    }

    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ name: MONTHLY_PASS_PRODUCT.name });
      await ctrl.activatePassAfterPayment({
        productId: String(product!._id),
        email: 'ruth@example.com',
        firstName: 'Ruth',
        stripeSessionId: 'cs_oneoff_view',
      });

      const res = mockRes();
      await ctrl.getMyPass(await signedInAs('ruth@example.com'), res);
      check('a one-off pass says it does not recur', res.body.pass.recurring === false);
      check('and offers no renewal date', !res.body.pass.nextChargeDate);
    }

    console.log(`\nALL ${passed} CHECKS PASSED`);
  } finally {
    await mongoose.disconnect();
    await mongod.stop();
  }
}

main().catch((e) => {
  console.error('\n', e.message || e);
  process.exit(1);
});
