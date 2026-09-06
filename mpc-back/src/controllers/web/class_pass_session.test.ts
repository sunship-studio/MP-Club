/**
 * Integration test for booking with a pass as a signed-in customer.
 * Run: npx ts-node src/controllers/web/class_pass_session.test.ts
 *
 * Replaces the pass-token flow: entitlement is now "the signed-in customer
 * holds a pass covering this class" (D16). D2's rule is unchanged — identity
 * still comes from the server, only its source moved from pass to session.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import Customer from '../../models/Customer';
import GroupClass from '../../models/GroupClass';
import Session from '../../models/Session';
import {
  LEGACY_QUARTERLY_PASS_PRODUCT,
  seedClassPassProduct,
} from '../../scripts/seed_class_passes';
import { activatePass } from '../../services/class_pass';
import { createSession, findOrCreateCustomer } from '../../services/auth';
import { activeSpotsFor, reserveSpot } from '../../services/group_class_booking';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const resend = require('../../config/resend').default;
resend.emails.send = async () => ({ data: { id: 'stub' }, error: null });

// eslint-disable-next-line @typescript-eslint/no-var-requires
const GroupClassController = require('./group_class_controller').default;
const ctrl = new GroupClassController();

const SLOT = '09:30 AM';
const IN_TERM = '2026-10-14';
const AFTER_TERM = '2026-12-14';
const WEEK_2 = '2026-10-21';

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

async function makeClass(spotsAvailable: number): Promise<string> {
  const gc = await GroupClass.create({
    title: 'TEST S&C',
    durationMinutes: 60,
    spotsAvailable,
    recurring: true,
    dayOfWeek: 'Wednesday',
    timeSlots: [{ time: SLOT, spots: [] }],
  });
  return (gc._id as mongoose.Types.ObjectId).toHexString();
}

/** A signed-in customer, and the cookie header that proves it. */
async function signIn(email: string, firstName = 'Mary') {
  const customer = await findOrCreateCustomer(email, { firstName, lastName: 'Byrne' });
  const session = await createSession(customer);
  return { customer, cookie: `mpc_session=${session}` };
}

async function givePass(email: string, overrides: Record<string, unknown> = {}) {
  const product = await ClassPassProduct.findOne({ active: true }).lean();
  return activatePass({
    productId: String(product!._id),
    email,
    firstName: 'Mary',
    lastName: 'Byrne',
    purchaseDate: '2026-09-01', // valid through 2026-12-01
    stripeSessionId: `cs_${Math.random()}`,
    ...overrides,
  });
}

async function book(cookie: string | null, body: Record<string, unknown>) {
  const res = mockRes();
  await ctrl.bookWithPass(
    { body, headers: cookie ? { cookie } : {} } as any,
    res
  );
  return res;
}

async function cancel(cookie: string | null, body: Record<string, unknown>) {
  const res = mockRes();
  await ctrl.cancelPassBooking(
    { body, headers: cookie ? { cookie } : {} } as any,
    res
  );
  return res;
}

async function myPass(cookie: string | null) {
  const res = mockRes();
  await ctrl.getMyPass({ headers: cookie ? { cookie } : {} } as any, res);
  return res;
}

async function spotsFor(classId: string, occurrenceDate: string) {
  const gc = await GroupClass.findById(classId).lean();
  return activeSpotsFor(gc!.timeSlots[0].spots, occurrenceDate, new Date());
}

async function reset() {
  await Promise.all([
    ClassPass.deleteMany({}),
    GroupClass.deleteMany({}),
    Customer.deleteMany({}),
    Session.deleteMany({}),
  ]);
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  await Promise.all([ClassPass.syncIndexes(), Session.syncIndexes(), Customer.syncIndexes()]);
  // Pinned to the 3-month product: these fixtures assert term dates (D17).
  await seedClassPassProduct(LEGACY_QUARTERLY_PASS_PRODUCT);
  try {
    // 1. What the site asks on page load
    {
      await reset();
      const anon = await myPass(null);
      check('an anonymous visitor is not signed in', anon.body.signedIn === false);
      check('an anonymous visitor holds no pass', anon.body.pass === null);

      const { cookie } = await signIn('mary@example.com');
      const noPass = await myPass(cookie);
      check('a signed-in customer without a pass is known', noPass.body.signedIn === true);
      check('a signed-in customer without a pass holds none', noPass.body.pass === null);

      await givePass('mary@example.com');
      const held = await myPass(cookie);
      check('a holder is told about their pass', held.body.pass !== null);
      check('the pass says when it ends', held.body.pass.validUntilDate === '2026-12-01');
      check('the pass is usable', held.body.pass.valid === true);
      check('no credential is handed back to the page',
        !JSON.stringify(held.body).toLowerCase().includes('token'));
    }

    // 2. Booking
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(10);

      const res = await book(cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      check('a signed-in holder books with no payment step', res.statusCode === 200);

      const spots = await spotsFor(classId, IN_TERM);
      check('the spot is confirmed immediately', (spots[0] as any).status === 'confirmed');
      check('the booking is under the signed-in identity',
        (spots[0] as any).email === 'mary@example.com');
    }

    // 3. Identity still comes from the server, never the request (D2)
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(10);

      await book(cookie, {
        classId,
        timeSlot: SLOT,
        occurrenceDate: IN_TERM,
        email: 'impostor@example.com',
        firstName: 'Someone',
      });

      const spots = await spotsFor(classId, IN_TERM);
      check('an email in the body is ignored',
        (spots[0] as any).email === 'mary@example.com');
      check('a name in the body is ignored', (spots[0] as any).firstName === 'Mary');
    }

    // 4. Not signed in, or signed in with no pass
    {
      await reset();
      const classId = await makeClass(10);

      const anon = await book(null, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      check('an anonymous booking is refused', anon.statusCode === 401);
      check('the refusal tells them to sign in', /sign in/i.test(String(anon.body.error)));

      const { cookie } = await signIn('nopass@example.com');
      const noPass = await book(cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      check('a signed-in customer with no pass is refused', noPass.statusCode === 403);
      check('they are pointed at buying one or paying per class',
        /pass/i.test(String(noPass.body.error)));
      check('no spot was taken', (await spotsFor(classId, IN_TERM)).length === 0);
    }

    // 5. The term still gates on the class date (D4)
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(10);

      const after = await book(cookie, {
        classId, timeSlot: SLOT, occurrenceDate: AFTER_TERM,
      });
      check('a class after the term is refused', after.statusCode === 403);
      check('the refusal names the end of the term',
        String(after.body.error).includes('2026-12-01'));
    }

    // 6. A lapsed pass
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com', { purchaseDate: '2025-01-01' });

      const status = await myPass(cookie);
      check('a lapsed holder is still signed in', status.body.signedIn === true);
      check('their pass is reported as unusable', status.body.pass.valid === false);
      check('their pass is reported as expired', status.body.pass.expired === true);

      const classId = await makeClass(10);
      const res = await book(cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      check('a lapsed holder cannot book free', res.statusCode === 403);
    }

    // 7. Revoked
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      const pass = await givePass('mary@example.com');
      pass.revoked = true;
      await pass.save();

      const classId = await makeClass(10);
      const res = await book(cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      check('a revoked pass cannot book', res.statusCode === 403);
    }

    // 8. No date fallback survives the redesign (D15)
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(10);

      const missing = await book(cookie, { classId, timeSlot: SLOT });
      check('a booking with no occurrence date is rejected', missing.statusCode === 400);

      const iso = await book(cookie, {
        classId, timeSlot: SLOT, date: '2026-10-14T00:00:00.000Z',
      });
      check('an ISO timestamp is not converted into an occurrence date',
        iso.statusCode === 400);
    }

    // 9. Capacity is still shared with paying customers
    {
      await reset();
      const { cookie } = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(1);

      const contenders = [
        book(cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM }),
        ...Array.from({ length: 10 }, (_, i) =>
          reserveSpot(GroupClass, {
            classId, timeSlot: SLOT, occurrenceDate: IN_TERM,
            email: `p${i}@example.com`, firstName: 'P',
            holdTtlMs: 600000, now: new Date(),
          })
        ),
      ];
      await Promise.all(contenders);
      check('exactly one of eleven concurrent bookers wins the last spot',
        (await spotsFor(classId, IN_TERM)).length === 1);
    }

    // 10. Cancelling (D6)
    {
      await reset();
      const mary = await signIn('mary@example.com');
      await givePass('mary@example.com');
      const classId = await makeClass(10);
      await book(mary.cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });
      await book(mary.cookie, { classId, timeSlot: SLOT, occurrenceDate: WEEK_2 });

      const res = await cancel(mary.cookie, {
        classId, timeSlot: SLOT, occurrenceDate: IN_TERM,
      });
      check('cancelling succeeds', res.statusCode === 200);
      check('the spot is released', (await spotsFor(classId, IN_TERM)).length === 0);
      check('the other week is untouched', (await spotsFor(classId, WEEK_2)).length === 1);

      const again = await cancel(mary.cookie, {
        classId, timeSlot: SLOT, occurrenceDate: IN_TERM,
      });
      check('cancelling twice is a 404', again.statusCode === 404);
    }

    // 11. A session cannot cancel somebody else's booking
    {
      await reset();
      const mary = await signIn('mary@example.com');
      const sean = await signIn('sean@example.com', 'Sean');
      await givePass('mary@example.com');
      await givePass('sean@example.com', { stripeSessionId: 'cs_sean' });
      const classId = await makeClass(10);
      await book(mary.cookie, { classId, timeSlot: SLOT, occurrenceDate: IN_TERM });

      const res = await cancel(sean.cookie, {
        classId, timeSlot: SLOT, occurrenceDate: IN_TERM,
      });
      check('one customer cannot cancel another\'s booking', res.statusCode === 404);
      check('the booking survives', (await spotsFor(classId, IN_TERM)).length === 1);

      const anon = await cancel(null, {
        classId, timeSlot: SLOT, occurrenceDate: IN_TERM,
      });
      check('an anonymous cancel is refused', anon.statusCode === 401);
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
