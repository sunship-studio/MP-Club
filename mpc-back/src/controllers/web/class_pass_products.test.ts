/**
 * Integration test for pass-product seeding and the public product listing.
 * Run: npx ts-node src/controllers/web/class_pass_products.test.ts
 *
 * See docs/specs/class-pass.md D11 — products are seeded, not admin-editable,
 * so the seed script is the only way a price ever changes.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import ClassPassProduct from '../../models/ClassPassProduct';
import {
  DEFAULT_PASS_PRODUCT,
  LEGACY_QUARTERLY_PASS_PRODUCT,
  retirePassProduct,
  seedClassPassProduct,
} from '../../scripts/seed_class_passes';

// The controller module constructs the Resend client at import time, which
// throws without a key. Tests never send mail, so a placeholder keeps the
// module loadable without weakening the real config's fail-fast behaviour.
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

async function listProducts() {
  const res = mockRes();
  await ctrl.getPassProducts({} as any, res);
  return res;
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  try {
    // 1. The seed creates the product Shane is selling
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct();

      const all = await ClassPassProduct.find().lean();
      check('seeding creates exactly one product', all.length === 1);
      check('the seeded product is the €90 / 1-month membership',
        all[0].months === 1 && all[0].priceCents === 9000 && all[0].currency === 'eur');
      check('the membership may be sold as a subscription',
        all[0].allowSubscription === true);
      check('the seeded product is on sale', all[0].active === true);
      check('the default matches what is seeded',
        DEFAULT_PASS_PRODUCT.months === 1 && DEFAULT_PASS_PRODUCT.priceCents === 9000);
    }

    // 2. Running the seed again is a no-op, not a duplicate
    {
      await ClassPassProduct.deleteMany({});
      const first = await seedClassPassProduct();
      const second = await seedClassPassProduct();

      const all = await ClassPassProduct.find().lean();
      check('running the seed twice leaves one product', all.length === 1);
      check('the second run returns the same product, not a new one',
        String(first._id) === String(second._id));
    }

    // 3. A price change supersedes rather than mutates — the pass someone
    //    already bought must keep pointing at what was actually sold
    {
      await ClassPassProduct.deleteMany({});
      const old = await seedClassPassProduct();
      const raised = await seedClassPassProduct({ ...DEFAULT_PASS_PRODUCT, priceCents: 35000 });

      const all = await ClassPassProduct.find().lean();
      check('a price change adds a product rather than editing one', all.length === 2);
      check('the new price is a different product', String(old._id) !== String(raised._id));

      const previous = await ClassPassProduct.findById(old._id).lean();
      check('the superseded product keeps the price it was sold at', previous!.priceCents === 9000);
      check('the superseded product is taken off sale', previous!.active === false);
      check('the new product is on sale', raised.active === true);
    }

    // 4. The website is told what is currently for sale
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct();
      const res = await listProducts();

      check('listing products succeeds', res.statusCode === 200);
      check('listing returns an array, so the site renders whatever comes back',
        Array.isArray(res.body));
      check('the active product is listed', res.body.length === 1);
      check('a listed product carries name, months and price',
        typeof res.body[0].name === 'string' &&
        res.body[0].months === 1 &&
        res.body[0].priceCents === 9000);
      check('a listed product carries an id the checkout can name',
        typeof res.body[0]._id !== 'undefined');
    }

    // 5. Superseded products are not offered for sale
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct();
      await seedClassPassProduct({ ...DEFAULT_PASS_PRODUCT, priceCents: 35000 });

      const res = await listProducts();
      check('only the product on sale is listed', res.body.length === 1);
      check('the listed product is the current price', res.body[0].priceCents === 35000);
    }

    // 6. Nothing on sale is an empty list, not an error
    {
      await ClassPassProduct.deleteMany({});
      const res = await listProducts();
      check('no products on sale returns 200 with an empty array',
        res.statusCode === 200 && Array.isArray(res.body) && res.body.length === 0);
    }

    // 7. D17: recurring is a property of the product, off unless asked for
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct({
        name: 'Drop-in Block',
        months: 1,
        priceCents: 5000,
        currency: 'eur',
      });

      const product = await ClassPassProduct.findOne({ name: 'Drop-in Block' }).lean();
      check('a product that does not ask for it cannot be sold recurring',
        product!.allowSubscription === false);
    }

    // 8. D17: the listing tells the page which products can recur
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct();

      const res = await listProducts();
      check('the listing carries allowSubscription', res.body[0].allowSubscription === true);
    }

    // 9. D17: the 3-month pass comes off sale without being deleted
    {
      await ClassPassProduct.deleteMany({});
      await seedClassPassProduct(LEGACY_QUARTERLY_PASS_PRODUCT);
      await seedClassPassProduct();

      const retired = await retirePassProduct(LEGACY_QUARTERLY_PASS_PRODUCT.name);
      check('retiring reports what it took off sale', retired === 1);

      const quarterly = await ClassPassProduct.findOne({
        name: LEGACY_QUARTERLY_PASS_PRODUCT.name,
      }).lean();
      check('the retired product still exists, so old passes still resolve it',
        quarterly !== null);
      check('the retired product is off sale', quarterly!.active === false);

      const res = await listProducts();
      check('only the monthly membership is on sale', res.body.length === 1);
      check('and it is the €90 one', res.body[0].priceCents === 9000);

      check('retiring again is a no-op',
        (await retirePassProduct(LEGACY_QUARTERLY_PASS_PRODUCT.name)) === 0);
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
