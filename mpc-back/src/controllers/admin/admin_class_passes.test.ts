/**
 * Integration test for admin pass management.
 * Run: npx ts-node src/controllers/admin/admin_class_passes.test.ts
 *
 * One list screen, a manual grant, revoke and resend — the failure this exists
 * for is Stripe taking the money while the webhook doesn't land. See D9, D12.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import GroupClass from '../../models/GroupClass';
import {
  LEGACY_QUARTERLY_PASS_PRODUCT,
  seedClassPassProduct,
} from '../../scripts/seed_class_passes';
import { activatePass, venueToday } from '../../services/class_pass';
import { activeSpotsFor } from '../../services/group_class_booking';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';

// Stub the mail transport: these tests are about what the admin endpoints do,
// and a real send would be a network call with a placeholder key.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const resend = require('../../config/resend').default;
let sent: { to: string; html: string }[] = [];
let mailFails = false;
resend.emails.send = async (payload: { to: string; html: string }) => {
  if (mailFails) throw new Error('Resend is down');
  sent.push(payload);
  return { data: { id: 'stub' }, error: null };
};

// eslint-disable-next-line @typescript-eslint/no-var-requires
const AdminAppController = require('./admin_app').default;
let cancelledSubscriptions: string[] = [];
let failNextCancel = false;

// eslint-disable-next-line @typescript-eslint/no-var-requires
const stripeClient = require('../../config/stripe').default;
stripeClient.subscriptions.cancel = async (id: string) => {
  if (failNextCancel) {
    failNextCancel = false;
    throw new Error('Stripe is unreachable');
  }
  cancelledSubscriptions.push(id);
  return { id, status: 'canceled' };
};

const ctrl = new AdminAppController();

const SLOT = '09:30 AM';
const WEEK = '2026-10-14';

function mockRes() {
  const r: any = { statusCode: 200, body: null };
  r.status = (c: number) => ((r.statusCode = c), r);
  r.json = (b: any) => ((r.body = b), r);
  return r;
}

let passed = 0;
function check(name: string, cond: boolean) {
  assert.ok(cond, `FAIL: ${name}`);
  console.log('  ✓', name);
  passed++;
}

async function makePass(email: string, overrides: Record<string, unknown> = {}) {
  const product = await ClassPassProduct.findOne({ active: true }).lean();
  return activatePass({
    productId: String(product!._id),
    email,
    firstName: email.split('@')[0],
    purchaseDate: venueToday(),
    stripeSessionId: `cs_${Math.random()}`,
    ...overrides,
  });
}

async function call(method: string, req: Record<string, unknown>) {
  const res = mockRes();
  await ctrl[method]({ body: {}, params: {}, query: {}, ...req } as any, res);
  return res;
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  await ClassPass.syncIndexes();
  // Pinned to the 3-month product: these fixtures assert term dates (D17).
  const product = await seedClassPassProduct(LEGACY_QUARTERLY_PASS_PRODUCT);
  try {
    // 1. The list: who holds a pass and when it runs out
    {
      await ClassPass.deleteMany({});
      sent = [];
      await makePass('mary@example.com');
      await makePass('sean@example.com', { purchaseDate: '2025-01-01' });
      const revoked = await makePass('paul@example.com');
      revoked.revoked = true;
      await revoked.save();

      const res = await call('listClassPasses', {});
      check('the list loads', res.statusCode === 200);
      check('every pass is listed', res.body.length === 3);

      const mary = res.body.find((p: any) => p.email === 'mary@example.com');
      check('a listed pass shows the holder', mary.firstName === 'mary');
      check('a listed pass shows when it expires', typeof mary.validUntilDate === 'string');
      check('a live pass reads as active', mary.status === 'active');

      const sean = res.body.find((p: any) => p.email === 'sean@example.com');
      check('a lapsed pass reads as expired', sean.status === 'expired');

      const paul = res.body.find((p: any) => p.email === 'paul@example.com');
      check('a revoked pass reads as revoked', paul.status === 'revoked');
    }

    // 2. The token never leaves the server. Shane resends the link by email
    //    rather than reading it off a screen he might screenshot or share.
    {
      const res = await call('listClassPasses', {});
      check('the list does not expose pass tokens',
        res.body.every((p: any) => !('token' in p)));
    }

    // 3. Finding one person among many
    {
      const res = await call('listClassPasses', { query: { search: 'MARY@example' } });
      check('the list can be searched by email, ignoring case', res.body.length === 1);
      check('search finds the right holder', res.body[0].email === 'mary@example.com');
    }

    // 4. The grant that earns the screen: Stripe took the money, the webhook
    //    never landed, and the customer is standing in front of Shane
    {
      await ClassPass.deleteMany({});
      sent = [];
      const res = await call('grantClassPass', {
        body: {
          productId: String(product._id),
          email: 'Walked.In@Example.com',
          firstName: 'Nuala',
          lastName: 'Kelly',
        },
      });

      check('granting succeeds', res.statusCode === 201);

      const granted = await ClassPass.findOne({ email: 'walked.in@example.com' });
      check('the pass exists', granted !== null);
      check('the pass is marked as an admin grant', granted!.grantedByAdmin === true);
      check('the pass has no Stripe session', !granted!.stripeSessionId);
      check('the pass starts today', granted!.validFromDate === venueToday());
      check('the pass carries the product term', granted!.months === 3);
      check('the holder is emailed their link', sent.length === 1);
      check('the email goes to the holder', sent[0].to === 'walked.in@example.com');
      check('the email contains a sign-in link', /sign-in\?token=/.test(sent[0].html));
    }

    // 5. A grant must not depend on the mail service being up
    {
      await ClassPass.deleteMany({});
      sent = [];
      mailFails = true;
      const res = await call('grantClassPass', {
        body: { productId: String(product._id), email: 'nomail@example.com', firstName: 'Ann' },
      });
      mailFails = false;

      check('the grant still succeeds when the email fails', res.statusCode === 201);
      check('the pass was still created',
        (await ClassPass.countDocuments({ email: 'nomail@example.com' })) === 1);
      check('the response says the email did not go out', res.body.emailSent === false);
    }

    // 6. Double-tap protection — the mistake D9 exists to undo
    {
      await ClassPass.deleteMany({});
      sent = [];
      await call('grantClassPass', {
        body: { productId: String(product._id), email: 'twice@example.com', firstName: 'Joe' },
      });
      const again = await call('grantClassPass', {
        body: { productId: String(product._id), email: 'twice@example.com', firstName: 'Joe' },
      });

      check('granting twice is refused', again.statusCode === 409);
      check('only one pass was created',
        (await ClassPass.countDocuments({ email: 'twice@example.com' })) === 1);
      check('the refusal says when the current pass ends',
        String(again.body.error).includes('valid until'));
    }

    // 7. Grant validation
    {
      const missing = await call('grantClassPass', { body: { email: 'x@y.com' } });
      check('granting without the required fields is a 400', missing.statusCode === 400);

      const unknown = await call('grantClassPass', {
        body: {
          productId: new mongoose.Types.ObjectId().toHexString(),
          email: 'x@y.com',
          firstName: 'X',
        },
      });
      check('granting an unknown product is a 404', unknown.statusCode === 404);
    }

    // 8. Revoke is an undo, and leaves bookings alone (D9)
    {
      await ClassPass.deleteMany({});
      await GroupClass.deleteMany({});
      const pass = await makePass('booked@example.com');
      const gc = await GroupClass.create({
        title: 'TEST S&C',
        durationMinutes: 60,
        spotsAvailable: 10,
        recurring: true,
        dayOfWeek: 'Wednesday',
        timeSlots: [
          {
            time: SLOT,
            spots: [
              {
                email: 'booked@example.com',
                firstName: 'Booked',
                occurrenceDate: WEEK,
                status: 'confirmed',
                bookedAt: new Date(),
              },
            ],
          },
        ],
      });

      const res = await call('setClassPassRevoked', {
        params: { id: String(pass._id) },
        body: { revoked: true },
      });
      check('revoking succeeds', res.statusCode === 200);
      check('the pass is revoked', (await ClassPass.findById(pass._id))!.revoked === true);

      const after = await GroupClass.findById(gc._id).lean();
      check('classes already booked still stand — revoke moves no spots',
        activeSpotsFor(after!.timeSlots[0].spots, WEEK, new Date()).length === 1);
    }

    // 9. A misclicked revoke is fixed by un-revoking, not by rebuilding a calendar
    {
      await ClassPass.deleteMany({});
      const pass = await makePass('oops@example.com');
      await call('setClassPassRevoked', {
        params: { id: String(pass._id) },
        body: { revoked: true },
      });
      const undo = await call('setClassPassRevoked', {
        params: { id: String(pass._id) },
        body: { revoked: false },
      });

      check('un-revoking succeeds', undo.statusCode === 200);
      check('the pass works again', (await ClassPass.findById(pass._id))!.revoked === false);
    }

    {
      const missing = await call('setClassPassRevoked', {
        params: { id: new mongoose.Types.ObjectId().toHexString() },
        body: { revoked: true },
      });
      check('revoking a pass that does not exist is a 404', missing.statusCode === 404);
    }

    // 10. Resend link — so Shane never has to ask a developer for a token
    {
      await ClassPass.deleteMany({});
      sent = [];
      const pass = await makePass('lost@example.com');

      const res = await call('resendClassPassLink', { params: { id: String(pass._id) } });
      check('resending succeeds', res.statusCode === 200);
      check('the email went out', sent.length === 1);
      check('the email carries a fresh sign-in link', /sign-in\?token=/.test(sent[0].html));
      check('the email goes to the holder', sent[0].to === 'lost@example.com');
      check('the response carries no credential back to the admin screen',
        !/token/i.test(JSON.stringify(res.body)));
    }

    {
      sent = [];
      mailFails = true;
      const pass = await ClassPass.findOne({ email: 'lost@example.com' });
      const res = await call('resendClassPassLink', { params: { id: String(pass!._id) } });
      mailFails = false;
      check('a failed resend is reported, not silently swallowed', res.statusCode === 500);
    }

    {
      const missing = await call('resendClassPassLink', {
        params: { id: new mongoose.Types.ObjectId().toHexString() },
      });
      check('resending for a pass that does not exist is a 404', missing.statusCode === 404);
    }

    // ---- D19: renewals are visible, and revoke stops the money ----

    {
      await ClassPass.deleteMany({});
      const oneOff = await ClassPass.create({
        email: 'once@example.com', firstName: 'Once', productId: product._id,
        months: 1, pricePaidCents: 9000,
        validFromDate: '2026-09-01', validUntilDate: '2026-10-01',
        revoked: false, purchasedAt: new Date(), grantedByAdmin: false,
      });
      const recurring = await ClassPass.create({
        email: 'ruth@example.com', firstName: 'Ruth', productId: product._id,
        months: 1, pricePaidCents: 9000,
        validFromDate: '2026-09-01', validUntilDate: '2026-10-01',
        revoked: false, purchasedAt: new Date(), grantedByAdmin: false,
        stripeSubscriptionId: 'sub_admin', autoRenew: true,
        subscriptionStatus: 'active', nextChargeDate: '2026-10-01',
      });

      const res = mockRes();
      await ctrl.listClassPasses({ query: {} } as any, res);
      const listed = new Map<string, any>(res.body.map((p: any) => [String(p._id), p]));

      check('a recurring pass is listed as recurring',
        listed.get(String(recurring._id)).recurring === true);
      check('and reports that it renews',
        listed.get(String(recurring._id)).autoRenew === true);
      check('and when the next charge falls',
        listed.get(String(recurring._id)).nextChargeDate === '2026-10-01');
      check('a one-off pass is listed as not recurring',
        listed.get(String(oneOff._id)).recurring === false);
      check('the subscription id is not exposed to the admin app',
        !('stripeSubscriptionId' in listed.get(String(recurring._id))));
    }

    // Revoking a subscription pass must stop the charges: a revoke that keeps
    // billing is a bug with a bank statement attached.
    {
      cancelledSubscriptions = [];
      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_admin' });

      const res = mockRes();
      await ctrl.setClassPassRevoked(
        { params: { id: String(pass!._id) }, body: { revoked: true } } as any,
        res
      );

      check('revoking succeeds', res.statusCode === 200);
      check('the Stripe subscription is cancelled outright, not at period end',
        cancelledSubscriptions.includes('sub_admin'));

      const after = await ClassPass.findById(pass!._id);
      check('the pass is revoked', after!.revoked === true);
      check('and no longer renews', after!.autoRenew === false);
      check('and is recorded as cancelled', after!.subscriptionStatus === 'canceled');
      check('and advertises no next charge', !after!.nextChargeDate);
    }

    // Un-revoking is an undo of the revoke, not of the cancellation.
    {
      cancelledSubscriptions = [];
      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_admin' });

      const res = mockRes();
      await ctrl.setClassPassRevoked(
        { params: { id: String(pass!._id) }, body: { revoked: false } } as any,
        res
      );

      const after = await ClassPass.findById(pass!._id);
      check('un-revoking restores the pass', after!.revoked === false);
      check('but does not resurrect the subscription', after!.autoRenew === false);
      check('and asks Stripe for nothing', cancelledSubscriptions.length === 0);
      check('the response says the subscription is gone for good',
        res.body.subscriptionEnded === true);
    }

    // Revoking a one-off pass touches Stripe at all.
    {
      cancelledSubscriptions = [];
      const oneOff = await ClassPass.findOne({ email: 'once@example.com' });

      const res = mockRes();
      await ctrl.setClassPassRevoked(
        { params: { id: String(oneOff!._id) }, body: { revoked: true } } as any,
        res
      );
      check('revoking a one-off pass succeeds', res.statusCode === 200);
      check('and asks Stripe for nothing', cancelledSubscriptions.length === 0);
    }

    // Stripe being unreachable must not leave the pass un-revoked: the
    // entitlement is ours to withdraw, the billing is a best effort.
    {
      cancelledSubscriptions = [];
      failNextCancel = true;
      const pass = await ClassPass.findOne({ stripeSubscriptionId: 'sub_admin' });
      await ClassPass.updateOne({ _id: pass!._id }, { $set: { subscriptionStatus: 'active' } });

      const res = mockRes();
      await ctrl.setClassPassRevoked(
        { params: { id: String(pass!._id) }, body: { revoked: true } } as any,
        res
      );

      check('the pass is revoked even when Stripe fails', res.statusCode === 200);
      check('the pass really is revoked',
        (await ClassPass.findById(pass!._id))!.revoked === true);
      check('and the failure is surfaced, not swallowed',
        res.body.subscriptionCancelFailed === true);
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
