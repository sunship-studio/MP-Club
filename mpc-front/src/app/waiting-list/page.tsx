'use client';
import AvailableBox from '@/components/waiting-list/available-box';
import CustomCheckbox from '@/components/waiting-list/Checkbox';
import AgeSlider from '@/components/waiting-list/slider';
import { z } from 'zod';
import TimeDropdown from '@/components/waiting-list/TimeDropdown';
import { useState } from 'react';
import ErrorText from '@/components/waiting-list/ErrorText';
import apiService, { DataState } from '@/services/api.service';
import Input from '@/components/waiting-list/input';

type Weekday = {
  name: string;
  value: boolean;
  startTime: string;
  endTime: string;
  allDay: boolean;
};

const WaitingList = () => {
  const [state, setState] = useState<DataState<any>>({
    status: 'initial',
  });

  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    age: 0,
  });

  const schema = z.object({
    firstName: z.string().min(2, 'First name is required'),
    lastName: z.string().min(2, 'Last name is required'),
    email: z.string().trim().email('Invalid email address'),
    age: z.number().min(18, 'You must be at least 18 years old'),
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'range' ? parseInt(value) : value,
    }));
  };

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [weekdaysErrors, setWeekdaysErrors] = useState<Record<string, string>>(
    {}
  );

  const [availableWeekdays, setAvailableWeekdays] = useState<Weekday[]>([
    {
      name: 'Monday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Tuesday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Wednesday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Thursday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Friday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Saturday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
    {
      name: 'Sunday',
      value: false,
      startTime: '',
      endTime: '',
      allDay: false,
    },
  ]);

  const validateForm = () => {
    try {
      const weekdayErrors: Record<string, string> = {};
      const selectedWeekdays = availableWeekdays.filter((day) => day.value);
      if (selectedWeekdays.length === 0) {
        weekdayErrors['weekdays'] = 'At least one weekday is required';
      }
      availableWeekdays.forEach((day, index) => {
        if (day.value && !day.allDay) {
          if (!day.startTime) {
            weekdayErrors[`weekdays.${index}.startTime`] =
              'Start time is required';
          }
          if (!day.endTime) {
            weekdayErrors[`weekdays.${index}.endTime`] = 'End time is required';
          }
        }
      });

      setWeekdaysErrors(weekdayErrors);
      schema.parse(formData);
      setFormErrors({});

      return Object.keys(weekdayErrors).length === 0;
    } catch (error) {
      if (error instanceof z.ZodError) {
        const newErrors: Record<string, string> = {};
        error.errors.forEach((err) => {
          if (err.path) {
            newErrors[err.path.join('.')] = err.message;
          }
        });
        setFormErrors(newErrors);
      }
      return false;
    }
  };

  const updateWeekdayValue = (weekday: string) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) =>
        day.name === weekday ? { ...day, value: !day.value } : day
      )
    );
  };

  const updateWeekdayStartTime = (weekday: string, startTime: string) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) => (day.name === weekday ? { ...day, startTime } : day))
    );
  };

  const updateWeekdayEndTime = (weekday: string, endTime: string) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) => (day.name === weekday ? { ...day, endTime } : day))
    );
  };

  const updateWeekdayAllDay = (weekday: string, allDay: boolean) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) => (day.name === weekday ? { ...day, allDay } : day))
    );
    setWeekdaysErrors((prev) => ({
      ...prev,
      [`weekdays.${availableWeekdays.findIndex(
        (day) => day.name === weekday
      )}.startTime`]: allDay
        ? ''
        : prev[
            `weekdays.${availableWeekdays.findIndex(
              (day) => day.name === weekday
            )}.startTime`
          ],
      [`weekdays.${availableWeekdays.findIndex(
        (day) => day.name === weekday
      )}.endTime`]: allDay
        ? ''
        : prev[
            `weekdays.${availableWeekdays.findIndex(
              (day) => day.name === weekday
            )}.endTime`
          ],
    }));
  };

  const handleSubmit = () => {
    const isValid = validateForm();

    if (isValid) {
      setState({ status: 'loading' });
      try {
        apiService.post('/waiting-list/add', {
          ...formData,
          availableWeekdays: availableWeekdays.filter((day) => day.value),
        });
        setState({ status: 'success', data: 'Form submitted successfully' });
      } catch (error) {
        setState({ status: 'error', error: 'Error submitting form' });
      }
    }
  };

  switch (state.status) {
    case 'initial':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          {/* Hero Section */}
          <div className="text-center mb-12">
            <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
              Join the Waiting List
            </h1>
            <p className="text-lg text-gray-200">
              Get exclusive access to 1-on-1 coaching when spots become
              available
            </p>
          </div>

          {/* Form Card */}
          <div className="bg-white/5 backdrop-blur rounded-lg p-8 md:p-10 shadow-xl border border-white/10">
            {/* Personal Information Section */}
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-white mb-6">
                Personal Information
              </h2>
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Input
                    label="First Name"
                    handleInputChange={handleInputChange}
                    id="firstName"
                  />
                  <ErrorText error={formErrors['firstName']} />
                </div>
                <div>
                  <Input
                    label="Last Name"
                    handleInputChange={handleInputChange}
                    id="lastName"
                  />
                  <ErrorText error={formErrors['lastName']} />
                </div>
              </div>
              <div className="mt-4">
                <Input
                  label="E-mail"
                  handleInputChange={handleInputChange}
                  id="email"
                />
                <ErrorText error={formErrors['email']} />
              </div>
              <div className="mt-4">
                <AgeSlider handleInputChange={handleInputChange} />
                <ErrorText error={formErrors['age']} />
              </div>
            </div>

            {/* Availability Section */}
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-white mb-6">
                When are you available?
              </h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                {availableWeekdays.map((day) => (
                  <AvailableBox
                    key={day.name}
                    weekday={day.name}
                    value={day.value}
                    setValue={updateWeekdayValue}
                  />
                ))}
              </div>
              <ErrorText error={weekdaysErrors['weekdays']} />
            </div>

            {/* Time Preferences */}
            {availableWeekdays.some((day) => day.value) && (
              <div className="mb-8">
                <h2 className="text-2xl font-bold text-white mb-6">
                  Time Preferences
                </h2>
                <div className="space-y-6">
                  {availableWeekdays.map(
                    (day, index) =>
                      day.value && (
                        <div
                          key={day.name}
                          className="bg-white/5 rounded-lg p-6 border border-white/10"
                        >
                          <div className="flex items-center justify-between mb-4">
                            <h3 className="text-lg font-semibold text-white">
                              {day.name}
                            </h3>
                            <CustomCheckbox
                              label="All Day"
                              checked={day.allDay}
                              onChange={() =>
                                updateWeekdayAllDay(day.name, !day.allDay)
                              }
                            />
                          </div>
                          {!day.allDay && (
                            <div className="grid md:grid-cols-2 gap-4">
                              <div>
                                <TimeDropdown
                                  label="Start Time"
                                  setTime={updateWeekdayStartTime}
                                  weekday={day}
                                />
                                <ErrorText
                                  error={
                                    weekdaysErrors[
                                      `weekdays.${index}.startTime`
                                    ]
                                  }
                                />
                              </div>
                              <div>
                                <TimeDropdown
                                  label="End Time"
                                  setTime={updateWeekdayEndTime}
                                  weekday={day}
                                />
                                <ErrorText
                                  error={
                                    weekdaysErrors[`weekdays.${index}.endTime`]
                                  }
                                />
                              </div>
                            </div>
                          )}
                        </div>
                      )
                  )}
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              onClick={handleSubmit}
              type="submit"
              className="w-full bg-[#0B79AB] text-white py-4 rounded-lg font-bold text-lg
                         hover:bg-[#0b78ab9e] transition-all duration-200
                         shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-100"
            >
              Join the Waiting List
            </button>
          </div>
        </div>
      );
    case 'loading':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12 text-center">
          <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10">
            <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-[#0B79AB] mx-auto mb-4"></div>
            <h1 className="text-2xl md:text-3xl font-semibold text-white">
              Submitting...
            </h1>
          </div>
        </div>
      );
    case 'success':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10 text-center">
            <div className="mb-6">
              <svg
                className="mx-auto h-24 w-24 text-green-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h1 className="text-3xl md:text-4xl font-bold mb-4 text-white">
              Thanks for signing up!
            </h1>
            <p className="text-xl text-gray-200">
              You will receive an email when we verify your application.
            </p>
          </div>
        </div>
      );
    case 'error':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-12 shadow-xl text-center">
            <div className="mb-6">
              <svg
                className="mx-auto h-24 w-24 text-red-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h1 className="text-3xl md:text-4xl font-bold mb-4 text-red-400">
              Oops! Something went wrong
            </h1>
            <p className="text-xl text-gray-200">
              Please try again or contact support if the problem persists.
            </p>
          </div>
        </div>
      );
  }
};

export default WaitingList;
