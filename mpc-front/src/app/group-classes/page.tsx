'use client';
import apiService from '@/services/api.service';
import { useEffect, useState } from 'react';

interface TimeSlot {
  time: string;
  spots: {
    firstName: string;
    lastName: string;
    email: string;
    bookedAt: string;
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
        console.log('Fetched classes:', response);
        setClasses(response);
      } catch (error) {
        console.error('Error fetching group classes:', error);
      } finally {
        setIsLoadingClasses(false);
      }
    };

    fetchGroupClasses();
  }, []);

  const generateCalendarDays = () => {
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const days: (Date | null)[] = [];

    const startingDayOfWeek = firstDay.getDay();

    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }

    for (let i = 1; i <= lastDay.getDate(); i++) {
      days.push(new Date(year, month, i));
    }

    return days;
  };

  const calendarDays = generateCalendarDays();

  const getClassesForDate = (date: Date | null): ClassWithAvailability[] => {
    if (!date) return [];

    const toLocalDateString = (d: Date) =>
      `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

    const dayOfWeek = date.toLocaleDateString('en-US', { weekday: 'long' });
    const dateString = toLocalDateString(date);

    console.log('Getting classes for:', dayOfWeek, dateString);

    return classes
      .map((cls) => {
        console.log('Checking class:', cls.title, 'timeSlots:', cls.timeSlots);

        // Filter by recurring classes that match this day OR specific date classes
        const isRecurringMatch =
          cls.recurring &&
          cls.dayOfWeek?.toLowerCase() === dayOfWeek.toLowerCase();
        const isDateMatch =
          !cls.recurring &&
          cls.date &&
          toLocalDateString(new Date(cls.date)) === dateString;

        if (!isRecurringMatch && !isDateMatch) {
          console.log(`Class ${cls.title} doesn't match this date`);
          return null;
        }

        if (!cls.timeSlots || cls.timeSlots.length === 0) {
          console.log('No timeSlots found for class:', cls.title);
          return null;
        }

        // Calculate availability for each time slot
        const timesWithSpots = cls.timeSlots.map((slot) => {
          const spotsTaken = slot.spots?.length || 0;
          return {
            time: slot.time,
            spotsTaken,
            spotsLeft: cls.spotsAvailable - spotsTaken,
          };
        });

        console.log('Times with spots for', cls.title, ':', timesWithSpots);

        return {
          ...cls,
          timesWithSpots,
        };
      })
      .filter((cls): cls is ClassWithAvailability => cls !== null);
  };

  const availableClasses = getClassesForDate(selectedDate);

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

  return (
    <div className="max-w-7xl mx-auto px-8 md:px-16 py-12 relative overflow-hidden">
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
          Group Classes
        </h1>
        <p className="text-lg text-gray-200">
          Join our energizing group workouts. Select a date and class below to
          book your spot.
        </p>
      </div>
      <div className="grid md:grid-cols-2 gap-8">
        <div className="bg-white rounded-lg p-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4 text-black">
            Select a Date
          </h2>
          <div className="grid grid-cols-7 gap-2">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <div
                key={day}
                className="text-center font-semibold text-gray-600 py-2"
              >
                {day}
              </div>
            ))}
            {calendarDays.map((date, index) => {
              if (!date) {
                return <div key={`empty-${index}`} className="py-3" />;
              }

              const isSelected =
                selectedDate?.toDateString() === date.toDateString();
              const isPast = date < new Date(new Date().setHours(0, 0, 0, 0));

              return (
                <button
                  key={date.toISOString()}
                  onClick={() => !isPast && setSelectedDate(date)}
                  disabled={isPast}
                  className={`
                    py-3 rounded-lg font-medium transition-all
                    ${
                      isSelected
                        ? 'bg-[#0B79AB] text-white shadow-lg scale-105'
                        : isPast
                          ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                          : 'bg-gray-50 text-black hover:bg-gray-200'
                    }
                  `}
                >
                  {date.getDate()}
                </button>
              );
            })}
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4 text-black">
            Available Classes
          </h2>
          {isLoadingClasses ? (
            <div className="flex justify-center items-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#0B79AB]"></div>
            </div>
          ) : !selectedDate ? (
            <p className="text-gray-600 text-center py-12">
              Please select a date to view available classes
            </p>
          ) : availableClasses.length === 0 ? (
            <p className="text-gray-600 text-center py-12">
              No classes available for this date
            </p>
          ) : (
            <div className="space-y-4">
              {availableClasses.map((classItem) => (
                <div
                  key={classItem._id}
                  className="border border-gray-200 rounded-lg p-4 hover:border-[#0B79AB] transition-all"
                >
                  <h3 className="font-semibold text-lg text-black">
                    {classItem.title}
                  </h3>
                  <p className="text-sm text-gray-600 mb-3">
                    {classItem.durationMinutes} min • {classItem.spotsAvailable}{' '}
                    spots per session
                  </p>
                  <div className="grid grid-cols-3 gap-2">
                    {classItem.timesWithSpots &&
                    classItem.timesWithSpots.length > 0 ? (
                      classItem.timesWithSpots.map((slot) => {
                        const isFull = slot.spotsLeft <= 0;
                        const isSelected =
                          selectedClass === `${classItem._id}-${slot.time}`;

                        return (
                          <button
                            key={slot.time}
                            onClick={() => {
                              console.log(
                                'Clicked:',
                                `${classItem._id}-${slot.time}`
                              );
                              setSelectedClass(`${classItem._id}-${slot.time}`);
                            }}
                            disabled={isFull}
                            className={`
                              py-2 px-3 rounded text-sm font-medium transition-all
                              ${
                                isSelected
                                  ? 'bg-[#0B79AB] text-white'
                                  : isFull
                                    ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                                    : 'bg-gray-100 text-black hover:bg-gray-200 cursor-pointer'
                              }
                            `}
                          >
                            <div>{slot.time}</div>
                            <div className="text-xs">
                              {isFull ? 'Full' : `${slot.spotsLeft} spots left`}
                            </div>
                          </button>
                        );
                      })
                    ) : (
                      <p className="text-gray-500 text-sm col-span-3">
                        No time slots available
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {selectedDate && selectedClass && (
        <div className="mt-8 bg-white rounded-lg p-8 shadow-xl">
          <h2 className="text-2xl font-semibold mb-6 text-black">
            Complete Your Booking
          </h2>

          <div className="bg-[#0B79AB]/5 rounded-lg p-6 mb-6">
            <h3 className="text-lg font-semibold mb-3 text-gray-900">
              Booking Details
            </h3>
            <div className="grid md:grid-cols-3 gap-4 text-black">
              <div>
                <p className="text-sm text-gray-600 mb-1">Date</p>
                <p className="font-semibold">
                  {selectedDate.toLocaleDateString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric',
                  })}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Time</p>
                <p className="font-semibold">{selectedClass.split('-')[1]}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Class</p>
                <p className="font-semibold">
                  {
                    classes.find((c) => c._id === selectedClass.split('-')[0])
                      ?.title
                  }
                </p>
              </div>
            </div>
          </div>

          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4 text-gray-900">
              Your Information
            </h3>
            <div className="grid md:grid-cols-2 gap-4">
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
                  className="w-full px-4 py-3 rounded-lg border-2 border-gray-200 focus:border-[#0B79AB] focus:outline-none transition-colors text-black placeholder:text-gray-400"
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
                  className="w-full px-4 py-3 rounded-lg border-2 border-gray-200 focus:border-[#0B79AB] focus:outline-none transition-colors text-black placeholder:text-gray-400"
                  required
                />
              </div>
            </div>
          </div>

          <button
            onClick={handleBooking}
            disabled={isSubmitting || !name || !email}
            className="w-full bg-[#0B79AB] text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-[#0b78ab9e] transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-105 active:scale-100"
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-2">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                Redirecting to payment...
              </span>
            ) : (
              'Pay €10 & Confirm Booking →'
            )}
          </button>
          <p className="text-center text-sm text-gray-500 mt-2">
            You will be redirected to our secure payment page
          </p>
        </div>
      )}

      <div className="mt-12 grid md:grid-cols-3 gap-6 text-center">
        <div className="bg-white/10 backdrop-blur rounded-lg p-6">
          <div className="text-4xl mb-2">🏋️</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Expert Trainers
          </h3>
          <p className="text-gray-200 text-sm">
            All classes led by certified fitness professionals
          </p>
        </div>
        <div className="bg-white/10 backdrop-blur rounded-lg p-6">
          <div className="text-4xl mb-2">👥</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Small Groups
          </h3>
          <p className="text-gray-200 text-sm">
            Limited spots ensure personalized attention
          </p>
        </div>
        <div className="bg-white/10 backdrop-blur rounded-lg p-6">
          <div className="text-4xl mb-2">📅</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Flexible Schedule
          </h3>
          <p className="text-gray-200 text-sm">
            Multiple time slots throughout the day
          </p>
        </div>
      </div>
    </div>
  );
}
