/**
 * Integration test for the profile page's data: what the signed-in member has
 * booked, split into what is still coming and what has already run.
 * Run: npx ts-node src/controllers/web/my_bookings.test.ts
 *
 * See docs/specs/class-pass.md D2 (identity from the session), D22 (a booking
 * says what paid for it).
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import Customer from '../../models/Customer';
import GroupClass from '../../models/GroupClass';
import Session from '../../models/Session';
import { createSession } from '../../services/auth';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const GroupClassController = require('./group_class_controller').default;

const ctrl = new GroupClassController();

const SLOT = '09:30 AM';
const LATE_SLOT = '06:00 PM';

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

function spot(email: string, occurrenceDate: string, extra: Record<string, unknown> = {}) {
  return {
    email,
    firstName: 'Ruth',
    lastName: 'Kelly',
    occurrenceDate,
    status: 'confirmed',
    bookedWithPass: true,
    bookedAt: new Date(),
    ...extra,
  };
}

async function signedInAs(email: string) {
  const customer = await Customer.findOne({ email });
  const raw = await createSession(customer!);
  return { headers: { cookie: `mpc_session=${raw}` }, body: {} } as any;
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  try {
    await Customer.create({ email: 'ruth@example.com', firstName: 'Ruth' });
    await Customer.create({ email: 'other@example.com', firstName: 'Other' });

    // 1. Bookings split into what is coming and what has run
    {
      await GroupClass.deleteMany({});
      await GroupClass.create({
        title: 'Conditioning',
        durationMinutes: 45,
        spotsAvailable: 10,
        recurring: true,
        dayOfWeek: 'Monday',
        timeSlots: [
          {
            time: SLOT,
            spots: [
              spot('ruth@example.com', '2026-09-01'),
              spot('ruth@example.com', '2026-09-20'),
              spot('other@example.com', '2026-09-20'),
            ],
          },
        ],
      });

      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });

      check('reading my bookings succeeds', res.statusCode === 200);
      check('a class still to come is upcoming', res.body.upcoming.length === 1);
      check('and it is the right one', res.body.upcoming[0].occurrenceDate === '2026-09-20');
      check('a class that has run is past', res.body.past.length === 1);
      check('and it is the right one', res.body.past[0].occurrenceDate === '2026-09-01');
      check('somebody else\'s booking is never returned',
        [...res.body.upcoming, ...res.body.past].every((b: any) => b.email === undefined));
    }

    // 2. A booking carries what the page needs to show it
    {
      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });
      const booking = res.body.upcoming[0];

      check('a booking names its class', booking.title === 'Conditioning');
      check('a booking carries its time', booking.timeSlot === SLOT);
      check('a booking carries its duration', booking.durationMinutes === 45);
      check('a booking carries the class id, so it can be cancelled',
        typeof booking.classId === 'string');
      check('a booking says a pass paid for it', booking.bookedWithPass === true);
    }

    // 3. Today's class is still upcoming until it has actually run
    {
      await GroupClass.deleteMany({});
      await GroupClass.create({
        title: 'Evening Session',
        durationMinutes: 60,
        spotsAvailable: 10,
        timeSlots: [{ time: LATE_SLOT, spots: [spot('ruth@example.com', '2026-09-06')] }],
      });

      const beforeIt = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), beforeIt, {
        today: '2026-09-06',
        nowMinutes: 9 * 60,
      });
      check('a class later today is still upcoming', beforeIt.body.upcoming.length === 1);

      const afterIt = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), afterIt, {
        today: '2026-09-06',
        nowMinutes: 19 * 60,
      });
      check('once it has started it is past', afterIt.body.past.length === 1);
      check('and no longer upcoming', afterIt.body.upcoming.length === 0);
    }

    // 4. A pending, unpaid hold is not a booking
    {
      await GroupClass.deleteMany({});
      await GroupClass.create({
        title: 'Strength',
        durationMinutes: 60,
        spotsAvailable: 10,
        timeSlots: [
          {
            time: SLOT,
            spots: [
              spot('ruth@example.com', '2026-09-20', {
                status: 'pending',
                holdId: 'h1',
                holdExpiresAt: new Date(Date.now() + 60000),
                bookedWithPass: false,
              }),
            ],
          },
        ],
      });

      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });
      check('an unpaid hold is not shown as a booking',
        res.body.upcoming.length === 0 && res.body.past.length === 0);
    }

    // 5. A paid single class is shown, and marked as not pass-paid
    {
      await GroupClass.deleteMany({});
      await GroupClass.create({
        title: 'Saturday Session',
        durationMinutes: 60,
        spotsAvailable: 10,
        timeSlots: [
          {
            time: SLOT,
            spots: [spot('ruth@example.com', '2026-09-20', { bookedWithPass: false })],
          },
        ],
      });

      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });
      check('a paid single class is still listed', res.body.upcoming.length === 1);
      check('and is marked as not paid for by a pass',
        res.body.upcoming[0].bookedWithPass === false);
    }

    // 6. Matching is case-insensitive, because booking email is free text
    {
      await GroupClass.deleteMany({});
      await GroupClass.create({
        title: 'Mixed Case',
        durationMinutes: 60,
        spotsAvailable: 10,
        timeSlots: [{ time: SLOT, spots: [spot('Ruth@Example.com', '2026-09-20')] }],
      });

      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });
      check('a booking made with a capitalised address is still mine',
        res.body.upcoming.length === 1);
    }

    // 7. Nothing booked is an empty answer, not an error
    {
      await GroupClass.deleteMany({});
      const res = mockRes();
      await ctrl.getMyBookings(await signedInAs('ruth@example.com'), res, {
        today: '2026-09-06',
        nowMinutes: 12 * 60,
      });
      check('no bookings is 200 with two empty lists',
        res.statusCode === 200 &&
        res.body.upcoming.length === 0 &&
        res.body.past.length === 0);
    }

    // 8. Identity comes from the session (D2)
    {
      const res = mockRes();
      await ctrl.getMyBookings({ headers: {}, body: {} } as any, res);
      check('an anonymous caller gets nothing', res.statusCode === 401);
    }

    console.log(`\nALL ${passed} CHECKS PASSED`);
  } finally {
    await Session.deleteMany({});
    await mongoose.disconnect();
    await mongod.stop();
  }
}

main().catch((e) => {
  console.error('\n', e.message || e);
  process.exit(1);
});
