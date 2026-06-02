/**
 * One-time migration: stamp legacy group-class bookings (no occurrenceDate)
 * onto the upcoming "first week" occurrence of their class, and mark them
 * confirmed, so they appear under the new per-week ticket pools.
 *
 * Idempotent: only fills missing occurrenceDate/status; already-stamped spots
 * are left untouched. Run: npx ts-node src/scripts/migrate_occurrence_dates.ts
 */
import dotenv from 'dotenv';
import mongoose from 'mongoose';

import GroupClass from '../models/GroupClass';
import { toLocalDateString } from '../services/group_class_booking';
dotenv.config();

const DAYS = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

function firstOccurrence(dayOfWeek: string): string {
  const target = DAYS.indexOf(dayOfWeek);
  const now = new Date();
  let delta = target - now.getDay();
  if (delta < 0) delta += 7; // today counts
  const d = new Date(now);
  d.setDate(now.getDate() + delta);
  return toLocalDateString(d);
}

async function main() {
  await mongoose.connect(process.env.MONGO_URI!);
  const classes = await GroupClass.find();
  let changedSpots = 0;
  for (const c of classes) {
    const occ =
      c.recurring && c.dayOfWeek
        ? firstOccurrence(c.dayOfWeek)
        : c.date
          ? toLocalDateString(new Date(c.date))
          : undefined;
    if (!occ) continue;

    let dirty = false;
    for (const slot of c.timeSlots as any[]) {
      for (const s of (slot.spots || []) as any[]) {
        if (!s.occurrenceDate) { s.occurrenceDate = occ; dirty = true; changedSpots++; }
      }
    }
    if (dirty) {
      c.markModified('timeSlots');
      await c.save();
      console.log(`Updated ${(c.title||'').trim()} | ${c.dayOfWeek ?? c.date} -> occ ${occ}`);
    }
  }

  // Persist confirmed status on every non-pending spot. Done as a raw update
  // because the schema's `status` default is applied in memory on load and so
  // is never seen as a change by save() — it would not otherwise persist.
  const statusRes = await GroupClass.updateMany(
    {},
    { $set: { 'timeSlots.$[].spots.$[s].status': 'confirmed' } },
    { arrayFilters: [{ 's.status': { $ne: 'pending' } }] }
  );

  console.log(
    `\nDone. Stamped occurrenceDate on ${changedSpots} legacy spot(s); ` +
      `confirmed status on ${statusRes.modifiedCount} class doc(s).`
  );
  await mongoose.disconnect();
}
main().catch((e) => { console.error(e); process.exit(1); });
