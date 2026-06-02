/**
 * Integration test for admin attendee scoping + save-merge safety.
 * Run: npx ts-node src/controllers/admin/admin_attendees.test.ts
 *
 * Verifies:
 *  - getGroupClasses shows only the upcoming occurrence's confirmed attendees
 *  - editGroupClass (the save path) does NOT destroy other weeks' bookings or
 *    in-flight pending holds when the editor saves a recurring class
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import AdminAppController from './admin_app';
import GroupClass from '../../models/GroupClass';
import { toLocalDateString } from '../../services/group_class_booking';

const SLOT = '09:30 AM';
const ctrl = new AdminAppController();

// next Tuesday-or-today, mirroring getNextDayOfWeek (today counts)
function nextDow(name: string): string {
  const days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  const target = days.indexOf(name);
  const now = new Date();
  let d = target - now.getDay();
  if (d < 0) d += 7;
  const date = new Date(now);
  date.setDate(now.getDate() + d);
  return toLocalDateString(date);
}

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

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  try {
    const thisWeek = nextDow('Tuesday');
    const otherWeek = toLocalDateString(
      new Date(new Date(thisWeek).getTime() + 7 * 86400000)
    );

    const gc = await GroupClass.create({
      title: 'FULL BODY S&C',
      durationMinutes: 60,
      spotsAvailable: 10,
      recurring: true,
      dayOfWeek: 'Tuesday',
      timeSlots: [
        {
          time: SLOT,
          spots: [
            { firstName: 'This', lastName: 'Week', email: 'this@x.com', occurrenceDate: thisWeek, status: 'confirmed' },
            { firstName: 'Other', lastName: 'Week', email: 'other@x.com', occurrenceDate: otherWeek, status: 'confirmed' },
            { firstName: 'Pending', lastName: 'Now', email: 'pend@x.com', occurrenceDate: thisWeek, status: 'pending', holdId: 'h1', holdExpiresAt: new Date(Date.now() + 600000) },
            { firstName: 'Legacy', lastName: 'Old', email: 'legacy@x.com' },
          ],
        },
      ],
    });
    const id = (gc._id as mongoose.Types.ObjectId).toHexString();

    // --- READ: only this-week confirmed shown ---
    const res = mockRes();
    await ctrl.getGroupClasses({} as any, res);
    const shown = res.body[0].timeSlots[0].spots;
    const emails = shown.map((s: any) => s.email).sort();
    check('admin sees only upcoming-occurrence confirmed attendee', emails.length === 1 && emails[0] === 'this@x.com');
    check('pending hold hidden from roster', !emails.includes('pend@x.com'));
    check('other week hidden from roster', !emails.includes('other@x.com'));

    // --- SAVE: editor removes the only shown attendee, posts back stripped spots ---
    const editReq: any = {
      body: {
        _id: id,
        title: 'FULL BODY S&C',
        durationMinutes: 60,
        spotsAvailable: 10,
        recurring: true,
        dayOfWeek: 'Tuesday',
        date: new Date(thisWeek),
        timeSlots: [{ time: SLOT, spots: [] }], // removed 'this@x.com'
      },
    };
    await ctrl.editGroupClass(editReq, mockRes());

    const after = await GroupClass.findById(id).lean();
    const allSpots = after!.timeSlots[0].spots;
    const allEmails = allSpots.map((s: any) => s.email).sort();
    check('removal honoured (this@x.com gone)', !allEmails.includes('this@x.com'));
    check('OTHER WEEK preserved across save', allEmails.includes('other@x.com'));
    check('pending hold preserved across save', allEmails.includes('pend@x.com'));
    check('legacy (other-occurrence) spot preserved', allEmails.includes('legacy@x.com'));
    const otherSpot = allSpots.find((s: any) => s.email === 'other@x.com');
    check('preserved other-week keeps its occurrenceDate', otherSpot?.occurrenceDate === otherWeek);

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
