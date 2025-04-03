'use client'
import { primaryColor } from "@/styles/constants";
import { parse } from "path";
import { ChangeEvent, ChangeEventHandler, useState } from "react";

const AgeSlider = ({ handleInputChange }: { handleInputChange: ChangeEventHandler }) => {
    const [age, setAge] = useState(0);

    const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
        setAge(parseInt(e.target.value));
    }

    return (
        <div className="w-full md:w-3/5 mx-auto flex items-center gap-3 py-4">
            <label htmlFor="age" className="text-lg font-semibold text-white whitespace-nowrap">
                Age
            </label>

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
                className="flex-1 h-1.5 bg-gray-200 rounded-lg appearance-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-[#118CC3] focus:ring-opacity-50 slider-thumb"
            />

            <p className="text-lg font-semibold text-white whitespace-nowrap">
                {age}
            </p>
        </div>
    );
}

export default AgeSlider;