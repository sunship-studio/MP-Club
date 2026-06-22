import mongoose from 'mongoose';

import { IGroupClass } from '../models/GroupClass';
import { toLocalDateString } from './group_class_booking';

const DAYS = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/**
 * The "YYYY-MM-DD" occurrence a booking truly belongs to, derived from the date
 * it was actually made (`bookedAt`). For a recurring class we snap forward to
 * that week's class day; for a one-off we use the class date. This is what an
 * earlier migration got wrong: it stamped EVERY legacy booking onto the next
 * upcoming occurrence, so old attendees squatted on the week people were trying
 * to book — producing a false "You have already booked this class".
 */
export function occurrenceFromBookedAt(
  bookedAt: Date,
  dayOfWeek?: string,
  classDate?: Date
): string | undefined {
  if (dayOfWeek) {
    const target = DAYS.indexOf(dayOfWeek);
    if (target < 0) return undefined;
    const d = new Date(bookedAt);
    const delta = (target - d.getDay() + 7) % 7; // snap forward to the class day
    d.setDate(d.getDate() + delta);
    return toLocalDateString(d);
  }
  if (classDate) return toLocalDateString(new Date(classDate));
  return toLocalDateString(new Date(bookedAt));
}

/**
 * Re-stamp legacy group-class bookings onto the occurrence they were actually
 * made for, undoing the earlier "everyone onto the upcoming week" migration.
 *
 * Safe + idempotent:
 *  - Only touches spots with NO `holdId` (legacy/free bookings). Paid Stripe
 *    bookings carry a holdId and already hold a correct occurrenceDate, so they
 *    are never moved.
 *  - For a correctly-stamped legacy spot the recomputed value equals the stored
 *    one, so re-running is a no-op.
 */
export async function repairOccurrenceDates(
  GroupClass: mongoose.Model<IGroupClass>
): Promise<{ stamped: number }> {
  const classes = await GroupClass.find();
  let stamped = 0;

  for (const c of classes) {
    let dirty = false;
    for (const slot of c.timeSlots as any[]) {
      for (const s of (slot.spots || []) as any[]) {
        if (s.holdId) continue; // paid booking — leave its occurrenceDate alone
        if (!s.bookedAt) continue;
        const occ = occurrenceFromBookedAt(
          new Date(s.bookedAt),
          c.dayOfWeek,
          c.date
        );
        if (occ && occ !== s.occurrenceDate) {
          s.occurrenceDate = occ;
          dirty = true;
          stamped++;
        }
      }
    }
    if (dirty) {
      c.markModified('timeSlots');
      await c.save();
    }
  }

  return { stamped };
}
