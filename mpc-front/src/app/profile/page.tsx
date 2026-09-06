'use client';

import MembershipPanel from '@/components/MembershipPanel';
import { Booking, cancelBooking, useMyBookings } from '@/hooks/useMyBookings';
import { useSession } from '@/hooks/useSession';
import {
  ArrowLeft,
  CalendarDays,
  Clock,
  Loader2,
  Ticket,
} from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

const BRAND = '#0B79AB';

/** "Sun 20 Sep 2026" — a date string, never a Date, so no timezone shifts (D4). */
function formatDate(date: string): string {
  const [year, month, day] = date.split('-').map(Number);
  return new Date(Date.UTC(year, month - 1, day)).toLocaleDateString('en-GB', {
    timeZone: 'UTC',
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

function BookingRow({
  booking,
  onCancel,
  isCancelling,
  faded,
}: {
  booking: Booking;
  onCancel?: () => void;
  isCancelling?: boolean;
  faded?: boolean;
}) {
  return (
    <li
      className={`flex flex-wrap items-center justify-between gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-3.5 ${
        faded ? 'opacity-60' : ''
      }`}
    >
      <div className="min-w-0">
        <p className="font-semibold text-white truncate">{booking.title}</p>
        <p className="mt-0.5 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-gray-300">
          <span className="inline-flex items-center gap-1.5">
            <CalendarDays className="h-3.5 w-3.5" />
            {formatDate(booking.occurrenceDate)}
          </span>
          <span className="inline-flex items-center gap-1.5">
            <Clock className="h-3.5 w-3.5" />
            {booking.timeSlot} · {booking.durationMinutes} min
          </span>
        </p>
      </div>

      {onCancel ? (
        booking.bookedWithPass ? (
          <button
            onClick={onCancel}
            disabled={isCancelling}
            className="shrink-0 rounded-lg border border-white/20 px-3 py-1.5 text-sm text-gray-200 transition-colors hover:bg-white/10 disabled:opacity-50"
          >
            {isCancelling ? 'Cancelling…' : 'Cancel'}
          </button>
        ) : (
          // A €10 class is real money back, which nobody here can decide (D22).
          <span className="shrink-0 text-xs text-gray-400">
            Paid separately — email us to cancel
          </span>
        )
      ) : null}
    </li>
  );
}

export default function ProfilePage() {
  const router = useRouter();
  const { session, isLoading: sessionLoading, refresh: refreshSession, signOut } =
    useSession();
  const { bookings, isLoading: bookingsLoading, error, refresh } = useMyBookings();
  const [cancellingKey, setCancellingKey] = useState<string | null>(null);
  const [cancelError, setCancelError] = useState<string | null>(null);

  // Nothing on this page means anything to a stranger, and every request it
  // makes would 401 anyway. Send them to sign in, and bring them back here.
  useEffect(() => {
    if (!sessionLoading && !session.signedIn) {
      router.replace('/sign-in?next=/profile');
    }
  }, [sessionLoading, session.signedIn, router]);

  const handleCancel = async (booking: Booking) => {
    const key = `${booking.classId}-${booking.timeSlot}-${booking.occurrenceDate}`;
    setCancellingKey(key);
    setCancelError(null);
    try {
      await cancelBooking(booking);
      await refresh();
    } catch (e) {
      setCancelError(e instanceof Error ? e.message : 'Please try again.');
    } finally {
      setCancellingKey(null);
    }
  };

  if (sessionLoading || !session.signedIn) {
    return (
      <div className="mx-auto max-w-3xl px-6 py-24 text-center">
        <Loader2 className="mx-auto h-10 w-10 animate-spin text-white/70" />
      </div>
    );
  }

  const pass = session.pass;

  return (
    <div className="mx-auto max-w-3xl px-6 py-12 md:px-12">
      <Link
        href="/group-classes"
        className="inline-flex items-center gap-2 text-sm text-gray-300 transition-colors hover:text-white"
      >
        <ArrowLeft className="h-4 w-4" /> Back to classes
      </Link>

      <div className="mt-6 mb-10">
        <h1 className="text-4xl font-bold tracking-tight text-white md:text-5xl">
          {session.firstName ? `Hello, ${session.firstName}` : 'Your account'}
        </h1>
        <p className="mt-2 text-gray-300">{session.email}</p>
      </div>

      {/* --- Membership --- */}
      <section className="mb-10">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-400">
          Membership
        </h2>

        {pass?.valid ? (
          <div className="space-y-3">
            <div className="rounded-2xl border border-emerald-400/30 bg-emerald-400/10 p-5">
              <p className="font-semibold text-emerald-200">
                {pass.productName} — active
              </p>
              <p className="mt-1 text-sm text-emerald-100/80">
                Every group class included up to and including{' '}
                {formatDate(pass.validUntilDate)}.
              </p>
            </div>
            <MembershipPanel pass={pass} onChanged={refreshSession} />
          </div>
        ) : pass ? (
          <div className="rounded-2xl border border-amber-400/30 bg-amber-400/10 p-5">
            <p className="font-semibold text-amber-200">
              {pass.revoked ? 'Your membership is not active' : 'Your membership has ended'}
            </p>
            <p className="mt-1 text-sm text-amber-100/80">
              {pass.revoked
                ? 'Get in touch and we will sort it out.'
                : `It ran until ${formatDate(pass.validUntilDate)}.`}
            </p>
            {!pass.revoked && (
              <Link
                href="/group-classes/passes"
                className="mt-3 inline-block rounded-xl px-4 py-2 text-sm font-semibold text-white"
                style={{ backgroundColor: BRAND }}
              >
                Start again →
              </Link>
            )}
          </div>
        ) : (
          <div className="rounded-2xl border border-white/10 bg-white/5 p-5">
            <div className="flex items-start gap-3">
              <Ticket className="mt-0.5 h-6 w-6 shrink-0" style={{ color: '#7CC7E8' }} />
              <div>
                <p className="font-semibold text-white">You don&apos;t have a membership</p>
                <p className="mt-1 text-sm text-gray-300">
                  Book classes one at a time, or get every class included each month.
                </p>
              </div>
            </div>
            <Link
              href="/group-classes/passes"
              className="mt-4 inline-block rounded-xl px-4 py-2 text-sm font-semibold text-white"
              style={{ backgroundColor: BRAND }}
            >
              See membership →
            </Link>
          </div>
        )}
      </section>

      {/* --- Upcoming --- */}
      <section className="mb-10">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-400">
          Coming up
        </h2>

        {cancelError && (
          <p className="mb-3 rounded-xl bg-red-500/10 px-4 py-3 text-sm text-red-300">
            {cancelError}
          </p>
        )}

        {bookingsLoading ? (
          <div className="flex justify-center py-10">
            <Loader2 className="h-8 w-8 animate-spin text-white/50" />
          </div>
        ) : bookings.upcoming.length === 0 ? (
          <div className="rounded-2xl border border-white/10 bg-white/5 p-6 text-center">
            <p className="text-gray-200">Nothing booked yet.</p>
            <Link
              href="/group-classes"
              className="mt-3 inline-block text-sm underline"
              style={{ color: '#7CC7E8' }}
            >
              Find a class
            </Link>
          </div>
        ) : (
          <ul className="space-y-2.5">
            {bookings.upcoming.map((booking) => {
              const key = `${booking.classId}-${booking.timeSlot}-${booking.occurrenceDate}`;
              return (
                <BookingRow
                  key={key}
                  booking={booking}
                  onCancel={() => handleCancel(booking)}
                  isCancelling={cancellingKey === key}
                />
              );
            })}
          </ul>
        )}
      </section>

      {/* --- Past --- */}
      <section className="mb-10">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-400">
          Classes you&apos;ve booked
        </h2>

        {bookings.past.length === 0 ? (
          <p className="rounded-2xl border border-white/10 bg-white/5 p-6 text-center text-gray-300">
            Nothing here yet.
          </p>
        ) : (
          <ul className="space-y-2.5">
            {bookings.past.map((booking) => (
              <BookingRow
                key={`${booking.classId}-${booking.timeSlot}-${booking.occurrenceDate}`}
                booking={booking}
                faded
              />
            ))}
          </ul>
        )}

        {/* The club records bookings, not who walked through the door (D22). */}
        <p className="mt-3 text-xs text-gray-500">
          This is what you booked, not attendance — we don&apos;t track who turned up.
        </p>
      </section>

      {error && (
        <p className="mb-6 rounded-xl bg-red-500/10 px-4 py-3 text-sm text-red-300">
          {error}
        </p>
      )}

      <button
        onClick={async () => {
          await signOut();
          router.replace('/group-classes');
        }}
        className="text-sm text-gray-400 underline transition-colors hover:text-gray-200"
      >
        Sign out
      </button>
    </div>
  );
}
