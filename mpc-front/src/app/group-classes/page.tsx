'use client';
import apiService from '@/services/api.service';
import apiClient from '@/services/api.client';
import { useSession } from '@/hooks/useSession';
import MembershipPanel from '@/components/MembershipPanel';
import Link from 'next/link';
import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Clock,
  Users,
  CalendarDays,
  CheckCircle2,
  Sparkles,
  Ticket,
  X,
} from 'lucide-react';

const BRAND = '#0B79AB';
const PRICE_LABEL = '€10';

// Local "YYYY-MM-DD" — avoids the UTC off-by-one that toISOString causes
const toLocalDateString = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(
    d.getDate()
  ).padStart(2, '0')}`;

interface TimeSlot {
  time: string;
  spots: {
    firstName: string;
    lastName: string;
    email: string;
    bookedAt: string;
    occurrenceDate?: string;
    status?: 'pending' | 'confirmed';
    holdExpiresAt?: string;
  }[];
}

interface GroupClass {
  _id: string;
  title: string;
  durationMinutes: number;
  timeSlots: TimeSlot[];
  date?: string;
  recurring?: boolean;
  dayOfWeek?: string;
  spotsAvailable: number;
}

interface ClassWithAvailability extends GroupClass {
  timesWithSpots: { time: string; spotsTaken: number; spotsLeft: number }[];
}

export default function GroupClassesPage() {
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedClass, setSelectedClass] = useState<string | null>(null);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [classes, setClasses] = useState<GroupClass[]>([]);
  const [isLoadingClasses, setIsLoadingClasses] = useState(true);

  const { session, refresh: refreshSession, signOut } = useSession();
  const pass = session.pass;
  const [passError, setPassError] = useState<string | null>(null);

  const fetchGroupClasses = useCallback(async () => {
    try {
      const response = await apiService.get<GroupClass[]>('/group-classes');
      setClasses(response);
    } catch (error) {
      console.error('Error fetching group classes:', error);
    } finally {
      setIsLoadingClasses(false);
    }
  }, []);

  useEffect(() => {
    void fetchGroupClasses();
  }, [fetchGroupClasses]);

  /** The signed-in customer's own spot in a given slot and week, if any. */
  const hasBooking = useCallback(
    (cls: GroupClass, time: string, date: Date) => {
      if (!session.signedIn || !session.email) return false;
      const occurrenceDate = toLocalDateString(date);
      const slot = cls.timeSlots.find((s) => s.time === time);
      return !!slot?.spots.some(
        (spot) =>
          spot.email?.toLowerCase() === session.email &&
          spot.occurrenceDate === occurrenceDate
      );
    },
    [session]
  );

  const bookWithPass = async (classId: string, timeSlot: string, date: Date) => {
    setIsSubmitting(true);
    setPassError(null);
    try {
      await apiClient.post('/group-classes/book-with-pass', {
        classId,
        timeSlot,
        // Never derived from a timestamp: an ISO conversion is a day out in
        // Irish summer time, right on the pass expiry boundary.
        occurrenceDate: toLocalDateString(date),
      });
      await fetchGroupClasses();
      await refreshSession();
      setSelectedClass(null);
    } catch (error: unknown) {
      setPassError(
        (error as { response?: { data?: { error?: string } } })?.response?.data?.error ??
          'We could not book that class. Please try again.'
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const cancelWithPass = async (classId: string, timeSlot: string, date: Date) => {
    setIsSubmitting(true);
    setPassError(null);
    try {
      await apiClient.post('/group-classes/cancel-with-pass', {
        classId,
        timeSlot,
        occurrenceDate: toLocalDateString(date),
      });
      await fetchGroupClasses();
    } catch (error: unknown) {
      setPassError(
        (error as { response?: { data?: { error?: string } } })?.response?.data?.error ??
          'We could not cancel that booking. Please try again.'
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const getClassesForDate = (date: Date | null): ClassWithAvailability[] => {
    if (!date) return [];

    const dayOfWeek = date.toLocaleDateString('en-US', { weekday: 'long' });
    const dateString = toLocalDateString(date);

    return classes
      .map((cls) => {
        // Recurring classes matching this weekday OR one-off classes on this date
        const isRecurringMatch =
          cls.recurring &&
          cls.dayOfWeek?.toLowerCase() === dayOfWeek.toLowerCase();
        const isDateMatch =
          !cls.recurring &&
          cls.date &&
          toLocalDateString(new Date(cls.date)) === dateString;

        if (!isRecurringMatch && !isDateMatch) return null;
        if (!cls.timeSlots || cls.timeSlots.length === 0) return null;

        // Availability for THIS occurrence only — each week has its own pool.
        // Count confirmed bookings plus still-live pending holds.
        const now = new Date();
        const timesWithSpots = cls.timeSlots.map((slot) => {
          const spotsTaken = (slot.spots || []).filter((s) => {
            if (s.occurrenceDate !== dateString) return false;
            if (s.status === 'pending') {
              return !!s.holdExpiresAt && new Date(s.holdExpiresAt) > now;
            }
            return true; // confirmed or legacy
          }).length;
          return {
            time: slot.time,
            spotsTaken,
            spotsLeft: cls.spotsAvailable - spotsTaken,
          };
        });

        return { ...cls, timesWithSpots };
      })
      .filter((cls): cls is ClassWithAvailability => cls !== null);
  };

  // Rolling 14-day strip starting today — recurring classes shine here
  const dayStrip = useMemo(() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return Array.from({ length: 14 }, (_, i) => {
      const d = new Date(today);
      d.setDate(today.getDate() + i);
      return { date: d, hasClasses: getClassesForDate(d).length > 0 };
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [classes]);

  // Auto-select the next day that actually has a class — zero clicks to value
  useEffect(() => {
    if (selectedDate || classes.length === 0) return;
    const firstOpen = dayStrip.find((d) => d.hasClasses);
    if (firstOpen) setSelectedDate(firstOpen.date);
  }, [dayStrip, classes, selectedDate]);

  const availableClasses = getClassesForDate(selectedDate);

  const selectedClassTitle = useMemo(() => {
    if (!selectedClass) return '';
    return classes.find((c) => c._id === selectedClass.split('-')[0])?.title ?? '';
  }, [selectedClass, classes]);

  const handleBooking = async () => {
    if (!name || !email || !selectedClass || !selectedDate) {
      alert('Please fill in all fields and select a class');
      return;
    }

    const [firstName, ...lastNameParts] = name.trim().split(' ');
    const lastName = lastNameParts.join(' ') || '';

    setIsSubmitting(true);

    try {
      const response = await apiService.post<{
        url: string;
        sessionId: string;
      }>('/group-classes/create-checkout-session', {
        classId: selectedClass.split('-')[0],
        timeSlot: selectedClass.split('-')[1],
        firstName,
        lastName,
        email,
        date: selectedDate.toISOString(),
        occurrenceDate: toLocalDateString(selectedDate),
      });

      if (response.url) {
        window.location.href = response.url;
      } else {
        throw new Error('No checkout URL received');
      }
    } catch (error: any) {
      console.error('Checkout error:', error);
      alert(
        error.response?.data?.error ||
          error.message ||
          'Failed to create checkout session. Please try again.'
      );
      setIsSubmitting(false);
    }
  };

  const scarcity = (left: number, total: number) => {
    if (left <= 0)
      return { label: 'Fully booked', tone: 'text-gray-400', bar: 'bg-gray-300' };
    if (left <= 2)
      return {
        label: `Only ${left} left`,
        tone: 'text-amber-600',
        bar: 'bg-amber-500',
      };
    return {
      label: `${left} of ${total} open`,
      tone: 'text-emerald-600',
      bar: 'bg-emerald-500',
    };
  };

  return (
    <div className="max-w-6xl mx-auto px-6 md:px-12 py-12 overflow-x-clip">
      {/* Hero */}
      <div className="text-center mb-10">
        <span className="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-4 py-1.5 text-sm font-medium text-white backdrop-blur">
          <Sparkles className="h-4 w-4" style={{ color: '#7CC7E8' }} />
          Small-group coaching · {PRICE_LABEL} drop-in
        </span>
        <h1 className="mt-5 text-4xl md:text-6xl font-bold text-white tracking-tight">
          Train together. <span style={{ color: '#7CC7E8' }}>Show up weekly.</span>
        </h1>
        <p className="mt-4 text-lg text-gray-200 max-w-2xl mx-auto">
          Our coached group classes run on a fixed weekly rhythm — pick your day,
          grab your spot, and build a habit that sticks. Spots are capped, so they
          go fast.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-x-8 gap-y-2 text-sm text-gray-300">
          <span className="inline-flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-400" /> Certified coach
          </span>
          <span className="inline-flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-400" /> Capped group sizes
          </span>
          <span className="inline-flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-400" /> Same time every week
          </span>
        </div>
      </div>

      {/* Pass state */}
      {pass?.valid ? (
        <div className="mb-8 rounded-2xl border border-emerald-400/30 bg-emerald-400/10 p-5 flex flex-wrap items-center justify-between gap-3">
          <div>
            <p className="font-semibold text-emerald-200">
              {session.firstName ?? 'You'}, your {pass.productName} is active.
            </p>
            <p className="text-sm text-emerald-100/80">
              Book any class below — no payment step. Valid until{' '}
              {pass.validUntilDate}
              {pass.recurring && pass.autoRenew
                ? `, renewing automatically${
                    pass.nextChargeDate ? ` on ${pass.nextChargeDate}` : ''
                  }.`
                : '.'}
            </p>
          </div>
          <div className="flex items-center gap-4">
            <Link
              href="/profile"
              className="text-sm font-semibold text-emerald-100 underline"
            >
              Your profile
            </Link>
            <button
              onClick={signOut}
              className="text-xs text-emerald-100/70 underline hover:text-emerald-100"
            >
              Sign out
            </button>
          </div>
        </div>
      ) : session.signedIn && pass ? (
        <div className="mb-8 rounded-2xl border border-amber-400/30 bg-amber-400/10 p-5">
          <p className="font-semibold text-amber-200">
            {pass.expired ? 'Your pass has ended' : 'Your pass is not active'}
          </p>
          <p className="text-sm text-amber-100/80 mt-1">
            {pass.expired
              ? `It ran until ${pass.validUntilDate}. Renew it, or book a single class for ${PRICE_LABEL}.`
              : 'Get in touch and we will sort it out.'}
          </p>
          <div className="mt-3 flex flex-wrap gap-4 text-sm">
            <Link href="/group-classes/passes" className="text-amber-100 underline">
              Renew your pass
            </Link>
            <Link href="/profile" className="text-amber-100 underline">
              Your profile
            </Link>
            <button onClick={signOut} className="text-amber-100/60 underline">
              Sign out
            </button>
          </div>
        </div>
      ) : session.signedIn ? (
        <div className="mb-8 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-white/15 bg-white/10 p-5 backdrop-blur">
          <div>
            <p className="font-semibold text-white">
              Signed in as {session.email}
            </p>
            <p className="text-sm text-gray-300">
              You don&apos;t have a pass. Book below for {PRICE_LABEL}, or get every
              class included.
            </p>
          </div>
          <div className="flex items-center gap-4">
            <Link
              href="/group-classes/passes"
              className="rounded-xl px-4 py-2 text-sm font-semibold text-white"
              style={{ backgroundColor: BRAND }}
            >
              See passes →
            </Link>
            <Link href="/profile" className="text-sm text-gray-300 underline">
              Your profile
            </Link>
            <button onClick={signOut} className="text-xs text-gray-400 underline">
              Sign out
            </button>
          </div>
        </div>
      ) : (
        <div className="mb-8 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-white/15 bg-white/10 p-5 backdrop-blur">
          <div className="flex items-start gap-3">
            <Ticket className="h-6 w-6 shrink-0 mt-0.5" style={{ color: '#7CC7E8' }} />
            <div>
              <p className="font-semibold text-white">
                Coming most weeks? Get a pass instead.
              </p>
              <p className="text-sm text-gray-300">
                Every class included for a fixed term — no {PRICE_LABEL} each time.
              </p>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <Link
              href="/group-classes/passes"
              className="rounded-xl px-4 py-2 text-sm font-semibold text-white"
              style={{ backgroundColor: BRAND }}
            >
              See passes →
            </Link>
            <Link href="/sign-in" className="text-sm text-gray-300 underline">
              Already have one? Sign in
            </Link>
          </div>
        </div>
      )}

      {/* The renewal switch, for a membership that actually recurs (D19). */}
      {pass && pass.recurring && (
        <div className="mb-8">
          <MembershipPanel pass={pass} onChanged={refreshSession} />
        </div>
      )}

      {passError && (
        <div className="mb-8 rounded-2xl bg-red-500/15 border border-red-400/30 p-4 text-sm text-red-100">
          {passError}
        </div>
      )}

      {/* Day strip */}
      <div className="mb-8">
        <div className="mb-3 flex items-center gap-2 text-white/90">
          <CalendarDays className="h-5 w-5" />
          <h2 className="text-lg font-semibold">Pick your day</h2>
        </div>
        <div className="flex gap-2.5 overflow-x-auto pb-2 pr-0 snap-x">
          {dayStrip.map(({ date, hasClasses }) => {
            const isSelected =
              selectedDate?.toDateString() === date.toDateString();
            const isToday = date.toDateString() === new Date().toDateString();
            return (
              <button
                key={date.toISOString()}
                onClick={() => {
                  setSelectedDate(date);
                  setSelectedClass(null);
                }}
                className={`snap-start shrink-0 w-[68px] rounded-2xl py-3 text-center transition-all border ${
                  isSelected
                    ? 'text-white border-transparent shadow-lg scale-105'
                    : hasClasses
                      ? 'bg-white/95 text-black border-transparent hover:bg-white hover:scale-105'
                      : 'bg-white/5 text-white/35 border-white/10'
                }`}
                style={isSelected ? { backgroundColor: BRAND } : undefined}
              >
                <div className="text-[11px] font-medium uppercase tracking-wide opacity-80">
                  {date.toLocaleDateString('en-US', { weekday: 'short' })}
                </div>
                <div className="text-xl font-bold leading-tight">
                  {date.getDate()}
                </div>
                <div className="mt-1 flex h-2 items-center justify-center">
                  {hasClasses ? (
                    <span
                      className={`h-1.5 w-1.5 rounded-full ${
                        isSelected ? 'bg-white' : 'bg-emerald-500'
                      }`}
                    />
                  ) : isToday ? (
                    <span className="text-[9px] opacity-60">today</span>
                  ) : null}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Classes */}
      <div className="mb-10">
        {isLoadingClasses ? (
          <div className="flex justify-center items-center py-16">
            <div
              className="animate-spin rounded-full h-12 w-12 border-b-2"
              style={{ borderColor: BRAND }}
            />
          </div>
        ) : !selectedDate ? (
          <p className="text-gray-300 text-center py-16">
            Select a day above to see what&apos;s on.
          </p>
        ) : availableClasses.length === 0 ? (
          <div className="rounded-2xl border border-white/10 bg-white/5 py-14 text-center">
            <p className="text-gray-200 font-medium">
              No classes on{' '}
              {selectedDate.toLocaleDateString('en-US', {
                weekday: 'long',
                month: 'short',
                day: 'numeric',
              })}
              .
            </p>
            <p className="text-gray-400 text-sm mt-1">
              Try a day marked with a green dot above.
            </p>
          </div>
        ) : (
          <div className="grid gap-5 md:grid-cols-2">
            {availableClasses.map((classItem) => (
              <div
                key={classItem._id}
                className="rounded-2xl bg-white p-6 shadow-xl ring-1 ring-black/5"
              >
                <div className="flex items-start justify-between gap-3">
                  <h3 className="text-xl font-bold text-black">
                    {classItem.title}
                  </h3>
                  {classItem.recurring && classItem.dayOfWeek && (
                    <span
                      className="shrink-0 rounded-full px-3 py-1 text-xs font-semibold"
                      style={{ backgroundColor: `${BRAND}14`, color: BRAND }}
                    >
                      Every {classItem.dayOfWeek}
                    </span>
                  )}
                </div>
                <div className="mt-2 flex items-center gap-4 text-sm text-gray-600">
                  <span className="inline-flex items-center gap-1.5">
                    <Clock className="h-4 w-4" /> {classItem.durationMinutes} min
                  </span>
                  <span className="inline-flex items-center gap-1.5">
                    <Users className="h-4 w-4" /> Max {classItem.spotsAvailable}
                  </span>
                </div>

                <div className="mt-5 space-y-2.5">
                  {classItem.timesWithSpots.length > 0 ? (
                    classItem.timesWithSpots.map((slot) => {
                      const isFull = slot.spotsLeft <= 0;
                      const isSelected =
                        selectedClass === `${classItem._id}-${slot.time}`;
                      const s = scarcity(slot.spotsLeft, classItem.spotsAvailable);
                      const pct = Math.max(
                        0,
                        Math.min(100, (slot.spotsLeft / classItem.spotsAvailable) * 100)
                      );
                      const booked =
                        !!selectedDate &&
                        hasBooking(classItem, slot.time, selectedDate);

                      // A slot the holder already has is not selectable — it
                      // shows what they hold and how to give it back (D6).
                      if (booked && selectedDate) {
                        return (
                          <div
                            key={slot.time}
                            className="w-full rounded-xl border-2 border-emerald-500 bg-emerald-50 px-4 py-3"
                          >
                            <div className="flex items-center justify-between gap-3">
                              <span className="text-base font-bold text-emerald-900">
                                {slot.time}
                              </span>
                              <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-700">
                                <CheckCircle2 className="h-4 w-4" /> You&apos;re booked
                              </span>
                            </div>
                            <button
                              onClick={() =>
                                cancelWithPass(classItem._id, slot.time, selectedDate)
                              }
                              disabled={isSubmitting}
                              className="mt-2 inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-800/70 underline hover:text-emerald-900 disabled:opacity-50"
                            >
                              <X className="h-3.5 w-3.5" />
                              Can&apos;t make it? Cancel and free the spot
                            </button>
                          </div>
                        );
                      }

                      return (
                        <button
                          key={slot.time}
                          onClick={() =>
                            setSelectedClass(`${classItem._id}-${slot.time}`)
                          }
                          disabled={isFull}
                          className={`w-full rounded-xl border-2 px-4 py-3 text-left transition-all ${
                            isSelected
                              ? 'text-white shadow-md'
                              : isFull
                                ? 'border-gray-100 bg-gray-50 cursor-not-allowed'
                                : 'border-gray-200 bg-white hover:border-gray-300 hover:shadow-sm'
                          }`}
                          style={
                            isSelected
                              ? { backgroundColor: BRAND, borderColor: BRAND }
                              : undefined
                          }
                        >
                          <div className="flex items-center justify-between">
                            <span
                              className={`text-base font-bold ${
                                isSelected
                                  ? 'text-white'
                                  : isFull
                                    ? 'text-gray-400'
                                    : 'text-black'
                              }`}
                            >
                              {slot.time}
                            </span>
                            <span
                              className={`text-xs font-semibold ${
                                isSelected ? 'text-white/90' : s.tone
                              }`}
                            >
                              {s.label}
                            </span>
                          </div>
                          <div
                            className={`mt-2 h-1.5 w-full overflow-hidden rounded-full ${
                              isSelected ? 'bg-white/30' : 'bg-gray-100'
                            }`}
                          >
                            <div
                              className={`h-full rounded-full ${
                                isSelected ? 'bg-white' : s.bar
                              }`}
                              style={{ width: `${pct}%` }}
                            />
                          </div>
                        </button>
                      );
                    })
                  ) : (
                    <p className="text-gray-500 text-sm">No time slots available</p>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Booking */}
      {selectedDate && selectedClass && (
        <div className="rounded-2xl bg-white p-6 md:p-8 shadow-2xl ring-1 ring-black/5">
          <h2 className="text-2xl font-bold mb-6 text-black">
            Lock in your spot
          </h2>

          <div
            className="rounded-xl p-5 mb-6"
            style={{ backgroundColor: `${BRAND}0D` }}
          >
            <div className="grid gap-4 md:grid-cols-3 text-black">
              <div>
                <p className="text-xs uppercase tracking-wide text-gray-500 mb-1">
                  Date
                </p>
                <p className="font-semibold">
                  {selectedDate.toLocaleDateString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric',
                  })}
                </p>
              </div>
              <div>
                <p className="text-xs uppercase tracking-wide text-gray-500 mb-1">
                  Time
                </p>
                <p className="font-semibold">{selectedClass.split('-')[1]}</p>
              </div>
              <div>
                <p className="text-xs uppercase tracking-wide text-gray-500 mb-1">
                  Class
                </p>
                <p className="font-semibold">{selectedClassTitle}</p>
              </div>
            </div>
          </div>

          {pass?.valid ? (
            <>
              <p className="mb-6 text-gray-700">
                Booking as <strong>{session.firstName ?? session.email}</strong> with
                your {pass.productName}. Nothing to pay.
              </p>
              <button
                onClick={() =>
                  selectedDate &&
                  bookWithPass(
                    selectedClass.split('-')[0],
                    selectedClass.split('-')[1],
                    selectedDate
                  )
                }
                disabled={isSubmitting}
                className="w-full text-white px-8 py-4 rounded-xl font-bold text-lg transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed hover:scale-[1.01] active:scale-100"
                style={{ backgroundColor: BRAND }}
              >
                {isSubmitting ? (
                  <span className="flex items-center justify-center gap-2">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white" />
                    Booking...
                  </span>
                ) : (
                  'Book free with your pass →'
                )}
              </button>
              <p className="text-center text-sm text-gray-500 mt-3">
                Included in your pass · cancel any time if plans change
              </p>
            </>
          ) : (
          <>
          <div className="grid gap-4 md:grid-cols-2 mb-6">
            <div>
              <label
                htmlFor="name"
                className="block text-sm font-semibold text-gray-700 mb-2"
              >
                Full Name
              </label>
              <input
                id="name"
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Enter your full name"
                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:outline-none transition-colors text-black placeholder:text-gray-400"
                style={{ caretColor: BRAND }}
                onFocus={(e) => (e.currentTarget.style.borderColor = BRAND)}
                onBlur={(e) => (e.currentTarget.style.borderColor = '')}
                required
              />
            </div>
            <div>
              <label
                htmlFor="email"
                className="block text-sm font-semibold text-gray-700 mb-2"
              >
                Email Address
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your.email@example.com"
                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:outline-none transition-colors text-black placeholder:text-gray-400"
                style={{ caretColor: BRAND }}
                onFocus={(e) => (e.currentTarget.style.borderColor = BRAND)}
                onBlur={(e) => (e.currentTarget.style.borderColor = '')}
                required
              />
            </div>
          </div>

          <button
            onClick={handleBooking}
            disabled={isSubmitting || !name || !email}
            className="w-full text-white px-8 py-4 rounded-xl font-bold text-lg transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed hover:scale-[1.01] active:scale-100"
            style={{ backgroundColor: BRAND }}
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-2">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white" />
                Redirecting to payment...
              </span>
            ) : (
              `Pay ${PRICE_LABEL} & confirm booking →`
            )}
          </button>
          <p className="text-center text-sm text-gray-500 mt-3">
            🔒 Secure checkout · spot held while you pay
          </p>
          </>
          )}
        </div>
      )}

      {/* Trust trio */}
      <div className="mt-14 grid gap-5 md:grid-cols-3 text-center">
        {[
          {
            icon: '🏋️',
            title: 'Your coach',
            body: 'Every class led by the same certified coach who knows your goals.',
          },
          {
            icon: '👥',
            title: 'Small groups',
            body: 'Capped numbers mean real, personal attention.',
          },
          {
            icon: '📅',
            title: 'Weekly rhythm',
            body: 'Same class, same time each week — easy to commit to.',
          },
        ].map((f) => (
          <div
            key={f.title}
            className="rounded-2xl bg-white/10 backdrop-blur p-6 border border-white/10"
          >
            <div className="text-4xl mb-2">{f.icon}</div>
            <h3 className="font-semibold text-lg mb-2 text-white">{f.title}</h3>
            <p className="text-gray-300 text-sm">{f.body}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
