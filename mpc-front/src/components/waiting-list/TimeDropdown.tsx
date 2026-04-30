'use client';
import { useState } from 'react';
import { ChevronDownIcon, ClockIcon } from 'lucide-react';

interface Weekday {
  name: string;
  value: boolean;
  startTime: string;
  endTime: string;
  allDay: boolean;
}

const TimeDropdown = ({
  label,
  setTime,
  weekday,
}: {
  label: string;
  setTime(weekday: string, time: string): void;
  weekday: Weekday;
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  const times = [
    '7:00 AM',
    '7:30 AM',
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
    '7:00 PM',
  ];

  return (
    <div className="relative w-full">
      <button
        type="button"
        className="flex items-center justify-between w-full px-4 py-3
                   bg-white/10 backdrop-blur rounded-lg text-white
                   border border-white/20
                   hover:bg-white/15 transition-all duration-200
                   focus:outline-none focus:ring-2 focus:ring-[#0B79AB]"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="flex items-center">
          <ClockIcon className="w-5 h-5 mr-2 text-gray-300" />
          <span className="font-medium text-sm">
            {selectedTime || label}
          </span>
        </div>
        <ChevronDownIcon
          className={`w-5 h-5 text-gray-300 transition-transform duration-200 ${
            isOpen ? 'rotate-180' : ''
          }`}
        />
      </button>

      {isOpen && (
        <div
          className="absolute z-10 w-full mt-2 bg-white rounded-lg shadow-xl
                     max-h-60 overflow-auto border border-gray-200"
        >
          {times.map((time) => (
            <div
              key={time}
              className="px-4 py-2.5 hover:bg-[#0B79AB] hover:text-white
                         cursor-pointer text-gray-800 transition-colors duration-150
                         first:rounded-t-lg last:rounded-b-lg font-medium text-sm"
              onClick={() => {
                setTime(weekday.name, time);
                setSelectedTime(time);
                setIsOpen(false);
              }}
            >
              {time}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default TimeDropdown;