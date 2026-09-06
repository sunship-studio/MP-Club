"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.occurrenceFromBookedAt = occurrenceFromBookedAt;
exports.repairOccurrenceDates = repairOccurrenceDates;
const group_class_booking_1 = require("./group_class_booking");
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
function occurrenceFromBookedAt(bookedAt, dayOfWeek, classDate) {
    if (dayOfWeek) {
        const target = DAYS.indexOf(dayOfWeek);
        if (target < 0)
            return undefined;
        const d = new Date(bookedAt);
        const delta = (target - d.getDay() + 7) % 7; // snap forward to the class day
        d.setDate(d.getDate() + delta);
        return (0, group_class_booking_1.toLocalDateString)(d);
    }
    if (classDate)
        return (0, group_class_booking_1.toLocalDateString)(new Date(classDate));
    return (0, group_class_booking_1.toLocalDateString)(new Date(bookedAt));
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
function repairOccurrenceDates(GroupClass) {
    return __awaiter(this, void 0, void 0, function* () {
        const classes = yield GroupClass.find();
        let stamped = 0;
        for (const c of classes) {
            let dirty = false;
            for (const slot of c.timeSlots) {
                for (const s of (slot.spots || [])) {
                    if (s.holdId)
                        continue; // paid booking — leave its occurrenceDate alone
                    if (!s.bookedAt)
                        continue;
                    const occ = occurrenceFromBookedAt(new Date(s.bookedAt), c.dayOfWeek, c.date);
                    if (occ && occ !== s.occurrenceDate) {
                        s.occurrenceDate = occ;
                        dirty = true;
                        stamped++;
                    }
                }
            }
            if (dirty) {
                c.markModified('timeSlots');
                yield c.save();
            }
        }
        return { stamped };
    });
}
