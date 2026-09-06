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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.toLocalDateString = toLocalDateString;
exports.isSpotActive = isSpotActive;
exports.activeSpotsFor = activeSpotsFor;
exports.reserveSpot = reserveSpot;
exports.confirmHold = confirmHold;
exports.releaseHold = releaseHold;
exports.slotMinutes = slotMinutes;
exports.venueClockMinutes = venueClockMinutes;
const mongoose_1 = __importDefault(require("mongoose"));
/** Local "YYYY-MM-DD" key — must match the occurrenceDate the frontend sends. */
function toLocalDateString(d) {
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
/**
 * A spot counts toward a week's pool when it is confirmed, or a pending hold
 * whose reservation window has not lapsed. Legacy spots (no status) are treated
 * as confirmed. This predicate is the single source of truth for capacity and
 * is reused by the reserve guard, the public availability read, and the
 * frontend display.
 */
function isSpotActive(spot, now) {
    if (spot.status === 'pending') {
        return !!spot.holdExpiresAt && new Date(spot.holdExpiresAt) > now;
    }
    return true; // 'confirmed' or legacy undefined
}
function activeSpotsFor(spots, occurrenceDate, now) {
    return spots.filter((s) => s.occurrenceDate === occurrenceDate && isSpotActive(s, now));
}
/**
 * Atomically reserve one pending spot in a week's pool.
 *
 * Capacity is enforced with an optimistic-concurrency (compare-and-swap) loop
 * on the document version key: we read, evaluate capacity in plain JS (the same
 * predicate used everywhere), then push only if `__v` is unchanged. MongoDB
 * serializes writes per document, so two concurrent reservations cannot both
 * see the same `__v` and both succeed — the loser retries against fresh state.
 */
function reserveSpot(GroupClass, params) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        const { classId, timeSlot, occurrenceDate, email, now } = params;
        for (let attempt = 0; attempt < 6; attempt++) {
            const gc = yield GroupClass.findById(classId).lean();
            if (!gc)
                return { ok: false, reason: 'notfound' };
            const slot = gc.timeSlots.find((s) => s.time === timeSlot);
            if (!slot)
                return { ok: false, reason: 'notfound' };
            const active = activeSpotsFor(slot.spots, occurrenceDate, now);
            if (active.some((s) => s.email === email)) {
                return { ok: false, reason: 'dup' };
            }
            if (active.length >= gc.spotsAvailable) {
                return { ok: false, reason: 'full' };
            }
            const holdId = new mongoose_1.default.Types.ObjectId().toHexString();
            const hold = {
                email,
                firstName: params.firstName,
                lastName: params.lastName,
                occurrenceDate,
                status: 'pending',
                holdId,
                holdExpiresAt: new Date(now.getTime() + params.holdTtlMs),
                bookedAt: now,
                bookedWithPass: (_a = params.bookedWithPass) !== null && _a !== void 0 ? _a : false,
            };
            // CAS: push only if the document version is still the one we read.
            const res = yield GroupClass.updateOne({ _id: classId, __v: gc.__v }, {
                $push: { 'timeSlots.$[t].spots': hold },
                $inc: { __v: 1 },
            }, { arrayFilters: [{ 't.time': timeSlot }] });
            if (res.modifiedCount === 1)
                return { ok: true, holdId };
            // Lost the race (version moved) — retry from fresh state.
        }
        return { ok: false, reason: 'conflict' };
    });
}
/** Promote a pending hold to confirmed. Idempotent: re-confirming is a no-op. */
function confirmHold(GroupClass, classId, holdId) {
    return __awaiter(this, void 0, void 0, function* () {
        const res = yield GroupClass.updateOne({ _id: classId, 'timeSlots.spots.holdId': holdId }, {
            $set: { 'timeSlots.$[t].spots.$[s].status': 'confirmed' },
            $unset: { 'timeSlots.$[t].spots.$[s].holdExpiresAt': '' },
        }, {
            arrayFilters: [
                { 't.spots.holdId': holdId },
                { 's.holdId': holdId },
            ],
        });
        return res.modifiedCount === 1;
    });
}
/** Release a pending hold (payment expired/cancelled). */
function releaseHold(GroupClass, classId, holdId) {
    return __awaiter(this, void 0, void 0, function* () {
        yield GroupClass.updateOne({ _id: classId }, { $pull: { 'timeSlots.$[].spots': { holdId, status: 'pending' } } });
    });
}
/**
 * A slot label like "09:30 AM" as minutes since midnight, or null if it is not
 * a shape we recognise. Slot times are free text typed in the admin app, so an
 * unparseable one must not silently become midnight.
 */
function slotMinutes(time) {
    var _a;
    const match = /^\s*(\d{1,2}):(\d{2})\s*(AM|PM)?\s*$/i.exec(time !== null && time !== void 0 ? time : '');
    if (!match)
        return null;
    let hours = Number(match[1]);
    const minutes = Number(match[2]);
    if (hours > 23 || minutes > 59)
        return null;
    const meridiem = (_a = match[3]) === null || _a === void 0 ? void 0 : _a.toUpperCase();
    if (meridiem) {
        if (hours < 1 || hours > 12)
            return null;
        if (meridiem === 'PM' && hours !== 12)
            hours += 12;
        if (meridiem === 'AM' && hours === 12)
            hours = 0;
    }
    return hours * 60 + minutes;
}
/** Minutes since midnight in the venue's own timezone (D4). */
function venueClockMinutes(now = new Date()) {
    const parts = new Intl.DateTimeFormat('en-GB', {
        timeZone: 'Europe/Dublin',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
    }).format(now);
    const [hours, minutes] = parts.split(':').map(Number);
    return hours * 60 + minutes;
}
