'use client';
import { ChangeEvent, ChangeEventHandler, useState } from 'react';

const AgeSlider = ({
  handleInputChange,
}: {
  handleInputChange: ChangeEventHandler;
}) => {
  const [age, setAge] = useState(0);

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setAge(parseInt(e.target.value));
  };

  return (
    <div className="w-full flex flex-col gap-4 py-6">
      <div className="flex items-center justify-between">
        <label htmlFor="age" className="text-sm font-semibold text-gray-200">
          Age
        </label>
        <div className="bg-[#0B79AB] px-4 py-2 rounded-lg min-w-[60px] text-center">
          <p className="text-2xl font-bold text-white">{age}</p>
        </div>
      </div>

      <div className="relative pt-1">
        <input
          type="range"
          id="age"
          name="age"
          min={0}
          max={80}
          value={age}
          onChange={(event) => {
            handleChange(event);
            handleInputChange(event);
          }}
          className="w-full h-2 bg-white/20 rounded-lg appearance-none cursor-pointer
                     focus:outline-none focus:ring-2 focus:ring-[#0B79AB] focus:ring-opacity-50
                     slider-thumb
                     backdrop-blur
                     border border-white/10"
        />
        <div className="flex justify-between text-xs text-gray-400 mt-2">
          <span>0</span>
          <span>80</span>
        </div>
      </div>
    </div>
  );
};

export default AgeSlider;