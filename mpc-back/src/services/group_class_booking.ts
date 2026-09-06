import mongoose from 'mongoose';

import { IGroupClass } from '../models/GroupClass';

/** Local "YYYY-MM-DD" key — must match the occurrenceDate the frontend sends. */
export function toLocalDateString(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(
    2,
    '0'
  )}-${String(d.getDate()).padStart(2, '0')}`;
}

type SpotLike = {
  email: string;
  occurrenceDate?: string;
  status?: 'pending' | 'confirmed';
  holdExpiresAt?: Date | string | null;
};

/**
 * A spot counts toward a week's pool when it is confirmed, or a pending hold
 * whose reservation window has not lapsed. Legacy spots (no status) are treated
 * as confirmed. This predicate is the single source of truth for capacity and
 * is reused by the reserve guard, the public availability read, and the
 * frontend display.
 */
export function isSpotActive(spot: SpotLike, now: Date): boolean {
  if (spot.status === 'pending') {
    return !!spot.holdExpiresAt && new Date(spot.holdExpiresAt) > now;
  }
  return true; // 'confirmed' or legacy undefined
}

export function activeSpotsFor(
  spots: SpotLike[],
  occurrenceDate: string,
  now: Date
): SpotLike[] {
  return spots.filter(
    (s) => s.occurrenceDate === occurrenceDate && isSpotActive(s, now)
  );
}

export type ReserveResult =
  | { ok: true; holdId: string }
  | { ok: false; reason: 'notfound' | 'full' | 'dup' | 'conflict' };

export interface ReserveParams {
  classId: string;
  timeSlot: string;
  occurrenceDate: string;
  email: string;
  firstName: string;
  lastName?: string;
  /** how long the hold stays valid; should outlast the Stripe session */
  holdTtlMs: number;
  now: Date;
  /** Whether a class pass is paying for this spot (D22). */
  bookedWithPass?: boolean;
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
export async function reserveSpot(
  GroupClass: mongoose.Model<IGroupClass>,
  params: ReserveParams
): Promise<ReserveResult> {
  const { classId, timeSlot, occurrenceDate, email, now } = params;

  for (let attempt = 0; attempt < 6; attempt++) {
    const gc = await GroupClass.findById(classId).lean<
      (IGroupClass & { __v: number }) | null
    >();
    if (!gc) return { ok: false, reason: 'notfound' };

    const slot = gc.timeSlots.find((s) => s.time === timeSlot);
    if (!slot) return { ok: false, reason: 'notfound' };

    const active = activeSpotsFor(slot.spots, occurrenceDate, now);
    if (active.some((s) => s.email === email)) {
      return { ok: false, reason: 'dup' };
    }
    if (active.length >= gc.spotsAvailable) {
      return { ok: false, reason: 'full' };
    }

    const holdId = new mongoose.Types.ObjectId().toHexString();
    const hold = {
      email,
      firstName: params.firstName,
      lastName: params.lastName,
      occurrenceDate,
      status: 'pending' as const,
      holdId,
      holdExpiresAt: new Date(now.getTime() + params.holdTtlMs),
      bookedAt: now,
      bookedWithPass: params.bookedWithPass ?? false,
    };

    // CAS: push only if the document version is still the one we read.
    const res = await GroupClass.updateOne(
      { _id: classId, __v: gc.__v },
      {
        $push: { 'timeSlots.$[t].spots': hold },
        $inc: { __v: 1 },
      },
      { arrayFilters: [{ 't.time': timeSlot }] }
    );

    if (res.modifiedCount === 1) return { ok: true, holdId };
    // Lost the race (version moved) — retry from fresh state.
  }

  return { ok: false, reason: 'conflict' };
}

/** Promote a pending hold to confirmed. Idempotent: re-confirming is a no-op. */
export async function confirmHold(
  GroupClass: mongoose.Model<IGroupClass>,
  classId: string,
  holdId: string
): Promise<boolean> {
  const res = await GroupClass.updateOne(
    { _id: classId, 'timeSlots.spots.holdId': holdId },
    {
      $set: { 'timeSlots.$[t].spots.$[s].status': 'confirmed' },
      $unset: { 'timeSlots.$[t].spots.$[s].holdExpiresAt': '' },
    },
    {
      arrayFilters: [
        { 't.spots.holdId': holdId },
        { 's.holdId': holdId },
      ],
    }
  );
  return res.modifiedCount === 1;
}

/** Release a pending hold (payment expired/cancelled). */
export async function releaseHold(
  GroupClass: mongoose.Model<IGroupClass>,
  classId: string,
  holdId: string
): Promise<void> {
  await GroupClass.updateOne(
    { _id: classId },
    { $pull: { 'timeSlots.$[].spots': { holdId, status: 'pending' } } }
  );
}

/**
 * A slot label like "09:30 AM" as minutes since midnight, or null if it is not
 * a shape we recognise. Slot times are free text typed in the admin app, so an
 * unparseable one must not silently become midnight.
 */
export function slotMinutes(time: string): number | null {
  const match = /^\s*(\d{1,2}):(\d{2})\s*(AM|PM)?\s*$/i.exec(time ?? '');
  if (!match) return null;

  let hours = Number(match[1]);
  const minutes = Number(match[2]);
  if (hours > 23 || minutes > 59) return null;

  const meridiem = match[3]?.toUpperCase();
  if (meridiem) {
    if (hours < 1 || hours > 12) return null;
    if (meridiem === 'PM' && hours !== 12) hours += 12;
    if (meridiem === 'AM' && hours === 12) hours = 0;
  }

  return hours * 60 + minutes;
}

/** Minutes since midnight in the venue's own timezone (D4). */
export function venueClockMinutes(now: Date = new Date()): number {
  const parts = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Europe/Dublin',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(now);
  const [hours, minutes] = parts.split(':').map(Number);
  return hours * 60 + minutes;
}
