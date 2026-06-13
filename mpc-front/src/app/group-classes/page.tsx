'use client';
import apiService from '@/services/api.service';
import { useEffect, useMemo, useState } from 'react';
import { Clock, Users, CalendarDays, CheckCircle2, Sparkles } from 'lucide-react';

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

  useEffect(() => {
    const fetchGroupClasses = async () => {
      try {
        setIsLoadingClasses(true);
        const response = await apiService.get<GroupClass[]>('/group-classes');
        setClasses(response);
      } catch (error) {
        console.error('Error fetching group classes:', error);
      } finally {
        setIsLoadingClasses(false);
      }
    };

    fetchGroupClasses();
  }, []);

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
