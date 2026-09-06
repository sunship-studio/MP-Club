/**
 * Integration test for buying a pass: activation from a paid session, the
 * one-active-pass rule, and the confirmation email.
 * Run: npx ts-node src/controllers/web/class_pass_purchase.test.ts
 *
 * The Stripe call itself is a boundary and is not exercised here — every
 * decision that matters (term, token, replay, stacking) is made either side
 * of it. See docs/specs/class-pass.md D1, D5, D7, D8, D14.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import {
  LEGACY_QUARTERLY_PASS_PRODUCT,
  seedClassPassProduct,
} from '../../scripts/seed_class_passes';
import {
  activatePass,
  findActivePassForEmail,
  renderPassPurchaseEmail,
} from '../../services/class_pass';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const GroupClassController = require('./group_class_controller').default;

const ctrl = new GroupClassController();

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

async function buy(productId: string, overrides: Record<string, unknown> = {}) {
  return activatePass({
    productId,
    email: 'mary@example.com',
    firstName: 'Mary',
    lastName: 'Byrne',
    purchaseDate: '2026-09-01',
    stripeSessionId: 'cs_test_1',
    ...overrides,
  });
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  await ClassPass.syncIndexes();
  try {
    // 1. A paid session turns into a usable pass
    {
      await ClassPass.deleteMany({});
      await ClassPassProduct.deleteMany({});
      // Pinned to the 3-month product so these date assertions keep exercising
      // multi-month term arithmetic, whatever is currently on sale (D17).
      const product = await seedClassPassProduct(LEGACY_QUARTERLY_PASS_PRODUCT);
      const pass = await buy(String(product._id));

      check('the pass runs from the purchase day', pass.validFromDate === '2026-09-01');
      check('the term comes from the product, not the caller', pass.validUntilDate === '2026-12-01');
      check('the pass records what was actually paid', pass.pricePaidCents === 30000);
      check('the pass records the months it was sold as', pass.months === 3);
      check('the pass points at the product it was sold under',
        String(pass.productId) === String(product._id));
      check('the holder is recorded for the door list', pass.firstName === 'Mary');
      check('a bought pass is not revoked', pass.revoked === false);
      check('a bought pass is not an admin grant', pass.grantedByAdmin === false);
    }

    // 2. A pass carries no credential of its own any more (D16)
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();
      const first = await buy(String(product!._id), { stripeSessionId: 'cs_a' });

      check('a pass stores no bearer token',
        !('token' in (first.toObject() as Record<string, unknown>)));
      check('a pass is identified by its holder instead',
        first.email === 'mary@example.com');
    }

    // 3. A replayed webhook must not mint a second pass (D14)
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();
      const first = await buy(String(product!._id), { stripeSessionId: 'cs_replay' });
      const replay = await buy(String(product!._id), { stripeSessionId: 'cs_replay' });

      check('replaying a session returns the existing pass',
        String(first._id) === String(replay._id));
      check('replaying a session does not extend the term',
        replay.validUntilDate === '2026-12-01');
      check('only one pass exists for the session', (await ClassPass.countDocuments({})) === 1);
    }

    // 4. Simultaneous redelivery is the same guarantee, under a race
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();
      const results = await Promise.all(
        Array.from({ length: 5 }, () =>
          buy(String(product!._id), { stripeSessionId: 'cs_race' })
        )
      );
      const ids = new Set(results.map((p) => String(p._id)));
      check('five simultaneous redeliveries produce one pass', ids.size === 1);
      check('the database holds one pass for the session',
        (await ClassPass.countDocuments({})) === 1);
    }

    // 5. The stacking check (D7)
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();
      await buy(String(product!._id), { stripeSessionId: 'cs_active' });

      check('a holder mid-term is found',
        (await findActivePassForEmail('mary@example.com', '2026-10-14')) !== null);
      check('a holder on their last day is still found',
        (await findActivePassForEmail('mary@example.com', '2026-12-01')) !== null);
      check('the day after expiry the holder is free to rebuy',
        (await findActivePassForEmail('mary@example.com', '2026-12-02')) === null);
      check('somebody else is not blocked by this pass',
        (await findActivePassForEmail('sean@example.com', '2026-10-14')) === null);
      check('email matching ignores case, since booking email is free text',
        (await findActivePassForEmail('MARY@Example.com', '2026-10-14')) !== null);
    }

    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();
      const pass = await buy(String(product!._id), { stripeSessionId: 'cs_revoked' });
      pass.revoked = true;
      await pass.save();
      check('a revoked pass does not block a rebuy (D9)',
        (await findActivePassForEmail('mary@example.com', '2026-10-14')) === null);
    }

    // 6. Checkout refuses before it ever reaches Stripe
    {
      await ClassPass.deleteMany({});
      const product = await ClassPassProduct.findOne({ active: true }).lean();

      const missing = mockRes();
      await ctrl.createPassCheckoutSession({ body: { email: 'x@y.com' } } as any, missing);
      check('checkout without the required fields is a 400', missing.statusCode === 400);

      const unknown = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: new mongoose.Types.ObjectId().toHexString(),
            email: 'x@y.com',
            firstName: 'X',
          },
        } as any,
        unknown
      );
      check('checkout for a product that does not exist is a 404', unknown.statusCode === 404);

      const superseded = await ClassPassProduct.create({
        ...LEGACY_QUARTERLY_PASS_PRODUCT,
        priceCents: 25000,
        active: false,
      });
      const offSale = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: { productId: String(superseded._id), email: 'x@y.com', firstName: 'X' },
        } as any,
        offSale
      );
      check('a superseded price cannot be bought', offSale.statusCode === 404);

      await buy(String(product!._id), { stripeSessionId: 'cs_stack' });
      const stacked = mockRes();
      await ctrl.createPassCheckoutSession(
        {
          body: {
            productId: String(product!._id),
            email: 'mary@example.com',
            firstName: 'Mary',
          },
        } as any,
        stacked
      );
      check('buying while a pass is active is a 409 (D7)', stacked.statusCode === 409);
      check('the 409 says when the current pass ends',
        typeof stacked.body?.error === 'string' && stacked.body.error.includes('2026-12-01'));
    }

    // 7. The confirmation email carries the credential and the terms (D5, D8)
    {
      const html = renderPassPurchaseEmail({
        firstName: 'Mary',
        productName: '3 Months Unlimited',
        signInLink: 'https://example.test/sign-in?token=TOKEN123',
        validUntilDate: '2026-12-01',
        pricePaidCents: 30000,
      });

      check('the email contains a sign-in link',
        html.includes('/sign-in?token=TOKEN123'));
      check('the email no longer carries a pass token', !html.includes('?pass='));
      check('the email states the exact expiry date', html.includes('2026-12-01'));
      check('the email states the pass is non-refundable (D5)',
        /non-refundable/i.test(html));
      check('the email shows what was paid', html.includes('300'));
      check('no template placeholders survive rendering', !/\{\{\w+\}\}/.test(html));
    }

    // 8. An index left behind by a removed field must not block sales
    {
      // Exactly the shape D16 left in production: `token` is gone from the
      // schema, but its unique non-sparse index survived, so the second pass
      // written collides on `token: null` and a paying customer gets nothing.
      await ClassPass.deleteMany({});
      await ClassPass.collection.createIndex({ token: 1 }, { unique: true, name: 'token_1' });

      await ClassPass.syncIndexes();
      const names = (await ClassPass.collection.indexes()).map((i: any) => i.name);
      check('syncing indexes drops the index of a field that no longer exists',
        !names.includes('token_1'));

      const product = await ClassPassProduct.findOne({ active: true }).lean();
      await buy(String(product!._id), { stripeSessionId: 'cs_idx_1' });
      await buy(String(product!._id), {
        stripeSessionId: 'cs_idx_2',
        email: 'second@example.com',
      });
      check('a second buyer can be sold a pass', (await ClassPass.countDocuments({})) === 2);
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
