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
