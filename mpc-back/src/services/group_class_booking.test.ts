/**
 * Concurrency test for the overbooking fix. Runs against a real (ephemeral)
 * mongod via mongodb-memory-server — a JS sim cannot exercise document-level
 * atomicity, which is where this fix's correctness lives.
 *
 * Run: npx ts-node src/services/group_class_booking.test.ts
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import GroupClass from '../models/GroupClass';
import {
  activeSpotsFor,
  confirmHold,
  releaseHold,
  reserveSpot,
} from './group_class_booking';

const OCC_A = '2026-06-09';
const OCC_B = '2026-06-16';
const SLOT = '09:30 AM';

async function makeClass(spotsAvailable: number): Promise<string> {
  const gc = await GroupClass.create({
    title: 'TEST S&C',
    durationMinutes: 60,
    spotsAvailable,
    recurring: true,
    dayOfWeek: 'Tuesday',
    timeSlots: [{ time: SLOT, spots: [] }],
  });
  return (gc._id as mongoose.Types.ObjectId).toHexString();
}

async function reserve(classId: string, occ: string, email: string, ttl = 600000) {
  return reserveSpot(GroupClass, {
    classId,
    timeSlot: SLOT,
    occurrenceDate: occ,
    email,
    firstName: 'T',
    holdTtlMs: ttl,
    now: new Date(),
  });
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
    // 1. THE race: capacity 1, 20 simultaneous distinct buyers → exactly 1 wins
    {
      const id = await makeClass(1);
      const results = await Promise.all(
        Array.from({ length: 20 }, (_, i) => reserve(id, OCC_A, `u${i}@x.com`))
      );
      const wins = results.filter((r) => r.ok).length;
      const fulls = results.filter((r) => !r.ok && r.reason === 'full').length;
      check('exactly 1 of 20 concurrent reservations wins', wins === 1);
      check('the other 19 are rejected (full/conflict)', wins + fulls <= 20 && wins === 1);

      const gc = await GroupClass.findById(id).lean();
      const active = activeSpotsFor(gc!.timeSlots[0].spots, OCC_A, new Date());
      check('DB holds exactly 1 active spot, not more', active.length === 1);
    }

    // 2. capacity 3, 30 concurrent → exactly 3 win
    {
      const id = await makeClass(3);
      const results = await Promise.all(
        Array.from({ length: 30 }, (_, i) => reserve(id, OCC_A, `u${i}@x.com`))
      );
      check('exactly 3 of 30 win when capacity=3', results.filter((r) => r.ok).length === 3);
    }

    // 3. per-week independence: filling week A leaves week B fully open
    {
      const id = await makeClass(1);
      const a = await reserve(id, OCC_A, 'a@x.com');
      const aFull = await reserve(id, OCC_A, 'b@x.com');
      const b = await reserve(id, OCC_B, 'a@x.com');
      check('week A reserves', a.ok);
      check('week A then full', !aFull.ok && aFull.reason === 'full');
      check('week B independent pool still open', b.ok);
    }

    // 4. dup email same occurrence rejected; same email next week allowed
    {
      const id = await makeClass(5);
      const first = await reserve(id, OCC_A, 'same@x.com');
      const dup = await reserve(id, OCC_A, 'same@x.com');
      const nextWk = await reserve(id, OCC_B, 'same@x.com');
      check('first booking ok', first.ok);
      check('duplicate same week rejected', !dup.ok && dup.reason === 'dup');
      check('same email next week allowed', nextWk.ok);
    }

    // 5. expired hold does not count → frees the pool
    {
      const id = await makeClass(1);
      const expired = await reserve(id, OCC_A, 'old@x.com', -1000); // already expired
      check('expired hold was written', expired.ok);
      const gc = await GroupClass.findById(id).lean();
      const active = activeSpotsFor(gc!.timeSlots[0].spots, OCC_A, new Date());
      check('expired hold is not active', active.length === 0);
      const fresh = await reserve(id, OCC_A, 'new@x.com');
      check('fresh reservation succeeds despite expired hold', fresh.ok);
    }

    // 6. confirmHold promotes; idempotent
    {
      const id = await makeClass(1);
      const r = await reserve(id, OCC_A, 'pay@x.com');
      assert.ok(r.ok);
      const ok1 = await confirmHold(GroupClass, id, (r as any).holdId);
      const ok2 = await confirmHold(GroupClass, id, (r as any).holdId);
      check('confirmHold promotes pending → confirmed', ok1 === true);
      check('confirmHold is idempotent (2nd is no-op)', ok2 === false);
      const gc = await GroupClass.findById(id).lean();
      check('spot is confirmed in DB', gc!.timeSlots[0].spots[0].status === 'confirmed');
    }

    // 7. releaseHold frees a pending spot
    {
      const id = await makeClass(1);
      const r = await reserve(id, OCC_A, 'gone@x.com');
      assert.ok(r.ok);
      await releaseHold(GroupClass, id, (r as any).holdId);
      const after = await reserve(id, OCC_A, 'next@x.com');
      check('released hold frees the pool', after.ok);
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
