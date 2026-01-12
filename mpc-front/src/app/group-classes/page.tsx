'use client';
import apiService from '@/services/api.service';
import { useEffect, useState } from 'react';

interface TimeSlot {
  time: string;
  spots: [];
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

  // Generate calendar days for current month
  const generateCalendarDays = () => {
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const days: (Date | null)[] = [];

    // Get the day of the week the month starts on (0 = Sunday, 6 = Saturday)
    const startingDayOfWeek = firstDay.getDay();

    // Add empty cells for days before the month starts
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }

    // Add all days of the month
    for (let i = 1; i <= lastDay.getDate(); i++) {
      days.push(new Date(year, month, i));
    }

    return days;
  };

  const calendarDays = generateCalendarDays();

  // Filter classes for the selected date
  const getClassesForDate = (date: Date | null) => {
    if (!date) return [];

    const dayOfWeek = date.toLocaleDateString('en-US', { weekday: 'long' });

    return classes.filter((cls) => {
      if (cls.recurring && cls.dayOfWeek) {
        return cls.dayOfWeek === dayOfWeek;
      }
      if (cls.date) {
        const classDate = new Date(cls.date);
        return classDate.toDateString() === date.toDateString();
      }
      return false;
    });
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
    console.log('Booking data:', {
      classId: selectedClass.split('-')[0],
      timeSlot: selectedClass.split('-')[1],
      firstName,
      lastName,
      email,
      date: selectedDate.toISOString(),
    });

    try {
      await apiService.post('/group-classes/book', {
        classId: selectedClass.split('-')[0],
        timeSlot: selectedClass.split('-')[1],
        firstName,
        lastName,
        email,
        date: selectedDate.toISOString(),
      });

      alert('Booking confirmed! Check your email for details.');
      setName('');
      setEmail('');
      setSelectedDate(null);
      setSelectedClass(null);

      // Refresh classes to update available spots
      const response = await apiService.get<GroupClass[]>('/group-classes');
      setClasses(response);
    } catch (error: any) {
      console.error('Booking error:', error);
      alert(
        error.response?.data?.message ||
          'Failed to complete booking. Please try again.'
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-8 md:px-16 py-12 relative overflow-hidden">
      {/* Disabled Overlay */}
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center group cursor-not-allowed">
        <div className="bg-white/10 backdrop-blur-md border-2 border-white/20 rounded-2xl px-8 md:px-12 py-6 md:py-8 transform transition-all opacity-100 md:opacity-0 md:group-hover:opacity-100 duration-300 mx-4">
          <p className="text-white text-2xl md:text-3xl font-bold text-center">
            Available Next Week 📅
          </p>
          <p className="text-gray-200 text-base md:text-lg text-center mt-2">
            Group classes coming soon!
          </p>
        </div>
      </div>
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
        {/* Calendar Section */}
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
                // Empty cell for days before the month starts
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

        {/* Class Selection Section */}
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
                    {classItem.timeSlots.map((slot) => (
                      <button
                        key={slot.time}
                        onClick={() =>
                          setSelectedClass(`${classItem._id}-${slot.time}`)
                        }
                        disabled={slot.spots.length >= classItem.spotsAvailable}
                        className={`
                          py-2 px-3 rounded text-sm font-medium transition-all
                          ${
                            selectedClass === `${classItem._id}-${slot.time}`
                              ? 'bg-[#0B79AB] text-white'
                              : slot.spots.length >= classItem.spotsAvailable
                                ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                                : 'bg-gray-100 text-black hover:bg-gray-200'
                          }
                        `}
                      >
                        <div>{slot.time}</div>
                        <div className="text-xs">
                          {slot.spots.length >= classItem.spotsAvailable
                            ? 'Full'
                            : `${classItem.spotsAvailable - slot.spots.length} spots left`}
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
      {/* Booking Summary & Sign Up Form */}
      {selectedDate && selectedClass && (
        <div className="mt-8 bg-white rounded-lg p-8 shadow-xl">
          <h2 className="text-2xl font-semibold mb-6 text-black">
            Complete Your Booking
          </h2>

          {/* Booking Details */}
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

          {/* Sign Up Form */}
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

          {/* Submit Button */}
          <button
            onClick={handleBooking}
            disabled={isSubmitting || !name || !email}
            className="w-full bg-[#0B79AB] text-white px-8 py-4 rounded-lg font-bold text-lg hover:bg-[#0b78ab9e] transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-105 active:scale-100"
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-2">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                Processing...
              </span>
            ) : (
              'Confirm Booking →'
            )}
          </button>
        </div>
      )}
      {/* Info Section */}
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
