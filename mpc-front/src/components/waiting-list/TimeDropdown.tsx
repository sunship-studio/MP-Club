"use client"
import { useState } from 'react';
import { ChevronDownIcon, ClockIcon } from 'lucide-react';
interface Weekday {
  name: string;
  value: boolean;
  startTime: string;
  endTime: string;
  allDay: boolean;
}
const TimeDropdown = ({ label, setTime, weekday }: { label: string, setTime(weekday: string, time: string): void, weekday: Weekday }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  const times = [
    "7:00 AM", "7:30 AM", "8:00 AM", "8:30 AM", "9:00 AM",
    "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
    "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM",
    "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM",
    "5:00 PM", "5:30 PM", "6:00 PM", "6:30 PM", "7:00 PM"
  ];

  return (
    <div className="relative">
      <button
        type="button"
        className="flex items-center justify-between w-full px-4 py-2 bg-gray-200 rounded-md text-gray-600"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="flex items-center">
          <ClockIcon className="w-5 h-5 mr-2 text-gray-500" />
          <span>{selectedTime || label}</span>
        </div>
        <ChevronDownIcon className="w-5 h-5 text-gray-500" />
      </button>

      {isOpen && (
        <div className="absolute z-10 w-full mt-1 bg-white rounded-md shadow-lg max-h-60 overflow-auto text-gray-800" >
          {times.map(time => (
            <div
              key={time}
              className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
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