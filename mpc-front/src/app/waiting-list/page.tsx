'use client';
import AvailableBox from "@/components/waiting-list/available-box";
import CustomCheckbox from "@/components/waiting-list/Checkbox";
import WaitingListInput from "@/components/waiting-list/input";
import AgeSlider from "@/components/waiting-list/slider";
import { number, set, z } from "zod";
import TimeDropdown from "@/components/waiting-list/TimeDropdown";
import { createContext, useContext, useState } from "react";
import ErrorText from "@/components/waiting-list/ErrorText";
type Weekday = {
  name: string;
  value: boolean;
  startTime: string;
  endTime: string;
  allDay: boolean;
}



const WaitingList = () => {
  // Form (all)
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    age: 0,
  });
  // Validation schema
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

  }
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [weekdaysErrors, setWeekdaysErrors] = useState<Record<string, string>>({});

  // Validate form
  const validateForm = () => {
    try {
      // Validate weekdays
      const weekdayErrors: Record<string, string> = {};
      // Check if any weekday is selected
      const selectedWeekdays = availableWeekdays.filter(day => day.value);
      if (selectedWeekdays.length === 0) {
        weekdayErrors['weekdays'] = 'At least one weekday is required';
      }
      availableWeekdays.forEach((day, index) => {

        if (day.value && !day.allDay) {

          if (!day.startTime) {
            weekdayErrors[`weekdays.${index}.startTime`] = "Start time is required";
          }
          if (!day.endTime) {
            weekdayErrors[`weekdays.${index}.endTime`] = "End time is required";
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
        error.errors.forEach(err => {
          if (err.path) {
            newErrors[err.path.join('.')] = err.message;
          }
        });
        setFormErrors(newErrors);
      }
      return false;
    }
  };





  // UI  // Available weekdays
  const [availableWeekdays, setAvailableWeekdays] = useState<Weekday[]>([
    { name: 'Monday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Tuesday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Wednesday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Thursday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Friday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Saturday', value: false, startTime: '', endTime: '', allDay: false },
    { name: 'Sunday', value: false, startTime: '', endTime: '', allDay: false }
  ],);

  const updateWeekdayValue = (weekday: string) => {

    setAvailableWeekdays((prev) =>
      prev.map((day) =>
        day.name === weekday ? { ...day, value: !day.value } : day
      )
    );



  }
  const updateWeekdayStartTime = (weekday: string, startTime: string) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) =>
        day.name === weekday ? { ...day, startTime } : day
      )
    );

  }

  const updateWeekdayEndTime = (weekday: string, endTime: string) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) =>
        day.name === weekday ? { ...day, endTime } : day
      )
    );

  }

  const updateWeekdayAllDay = (weekday: string, allDay: boolean) => {
    setAvailableWeekdays((prev) =>
      prev.map((day) =>
        day.name === weekday ? { ...day, allDay } : day
      )
    );
    setWeekdaysErrors((prev) => ({
      ...prev,
      [`weekdays.${availableWeekdays.findIndex(day => day.name === weekday)}.startTime`]: allDay ? '' : prev[`weekdays.${availableWeekdays.findIndex(day => day.name === weekday)}.startTime`],
      [`weekdays.${availableWeekdays.findIndex(day => day.name === weekday)}.endTime`]: allDay ? '' : prev[`weekdays.${availableWeekdays.findIndex(day => day.name === weekday)}.endTime`],
    }));
  }
  const handleSubmit = () => {
    const isValid = validateForm();

    if (isValid) {

      console.log({
        ...formData,
        availableWeekdays: availableWeekdays.filter(day => day.value)
      });


    };
  }

  return (
    <div className="flex flex-col items-center justify-center py-8 px-6">
      <h1 className={`text-2xl md:text-3xl font-semibold mb-4 text-center`} >Waiting List for 1-on-1 Coaching</h1>
      <div className="flex flex-col w-full md:w-2/3 ">
        {/* Desktop Text Inputs */}
        <div className="hidden md:flex flex-col w-full space-y-2 py-2">
          <div className="flex flex-row w-full space-x-5">
            <div className="flex flex-col w-full">
              <WaitingListInput label="First Name" handleInputChange={handleInputChange} id="firstName" />
              <ErrorText error={formErrors['firstName']} />
            </div>
            <div className="flex flex-col w-full">
              <WaitingListInput label="Last Name" handleInputChange={handleInputChange} id='lastName' />
              <ErrorText error={formErrors['lastName']} />
            </div>
          </div>
          <div className="flex flex-col w-full">
            <WaitingListInput label="E-mail" handleInputChange={handleInputChange} id='email' />
            <ErrorText error={formErrors['email']} />
          </div>
        </div>
        {/* Mobile Text Inputs */}
        <div className="flex flex-col md:hidden w-full">
          <WaitingListInput label="First Name" handleInputChange={handleInputChange} id="firstName" />
          <ErrorText error={formErrors['firstName']} />
          <WaitingListInput label="Last Name" handleInputChange={handleInputChange} id='lastName' />
          <ErrorText error={formErrors['lastName']} />
          <WaitingListInput label="E-mail" handleInputChange={handleInputChange} id='email' />
          <ErrorText error={formErrors['email']} />
        </div>
      </div>
      <div className="flex flex-col w-full md:w-2/3 ">
        <AgeSlider handleInputChange={handleInputChange} />
        <ErrorText error={formErrors['age']} />
      </div>

      <h2 className="text-lg font-semibold text-left w-full md:w-2/3" >I am available on: </h2>
      {/* Desktop Available */}
      <div className="hidden md:flex flex-row w-2/3 space-x-2">
        <AvailableBox weekday={availableWeekdays[0]['name']} value={availableWeekdays[0]["value"]} setValue={updateWeekdayValue} />
        <AvailableBox weekday={availableWeekdays[1]['name']} value={availableWeekdays[1]["value"]} setValue={updateWeekdayValue} />
        <AvailableBox weekday={availableWeekdays[2]['name']} value={availableWeekdays[2]["value"]} setValue={updateWeekdayValue} />
        <AvailableBox weekday={availableWeekdays[3]['name']} value={availableWeekdays[3]["value"]} setValue={updateWeekdayValue} />
        <AvailableBox weekday={availableWeekdays[4]['name']} value={availableWeekdays[4]["value"]} setValue={updateWeekdayValue} />
        <AvailableBox weekday={availableWeekdays[5]['name']} value={availableWeekdays[5]["value"]} setValue={updateWeekdayValue} />

      </div>
      {/* Mobile Available */}

      <div className="flex flex-col w-full md:hidden space-y-2 py-2">
        <div className="flex-row w-full flex space-x-2 ">
          <AvailableBox weekday={availableWeekdays[0]['name']} value={availableWeekdays[0]["value"]} setValue={updateWeekdayValue} />
          <AvailableBox weekday={availableWeekdays[1]['name']} value={availableWeekdays[1]["value"]} setValue={updateWeekdayValue} />
          <AvailableBox weekday={availableWeekdays[2]['name']} value={availableWeekdays[2]["value"]} setValue={updateWeekdayValue} />
        </div> <div className="flex-row w-full flex space-x-2">

          <AvailableBox weekday={availableWeekdays[3]['name']} value={availableWeekdays[3]["value"]} setValue={updateWeekdayValue} />
          <AvailableBox weekday={availableWeekdays[4]['name']} value={availableWeekdays[4]["value"]} setValue={updateWeekdayValue} />
          <AvailableBox weekday={availableWeekdays[5]['name']} value={availableWeekdays[5]["value"]} setValue={updateWeekdayValue} />
        </div>
        <ErrorText error={weekdaysErrors['weekdays']} />
      </div>

      {/* Time dropdowns */}
      <div className="flex flex-col items-start w-full md:w-2/3 mb-4" >
        {
          availableWeekdays.map((day, index) => (
            day.value && (

              <div className="flex flex-col w-full md:w-2/3 space-y-2 py-2" key={day.name}>
                <div className="flex flex-row w-full space-x-2 items-center ">
                  <p className="font-semibold text-lg text-left ">{day.name}</p>
                  <CustomCheckbox label="All Day" checked={day.allDay} onChange={() => updateWeekdayAllDay(day.name, !day.allDay)} />
                </div>
                {!day.allDay && <div className="flex flex-row w-full space-x-2">
                  <TimeDropdown label="Start Time" setTime={updateWeekdayStartTime} weekday={day} />
                  <TimeDropdown label="End Time" setTime={updateWeekdayEndTime} weekday={day} />
                </div>}
                <ErrorText error={weekdaysErrors[`weekdays.${index}.startTime`]} />
                <ErrorText error={weekdaysErrors[`weekdays.${index}.endTime`]} />

              </div>

            )
          )
          )
        }
      </div>
      {/* Submit button */}
      <button onClick={handleSubmit} type="submit" className="flex flex-col items-center justify-center w-full md:w-2/3 py-3 bg-[#118CC3] font-semibold rounded-lg" >
        Join the waiting list
      </button>
    </div>
  );
}

export default WaitingList;

