"use client"
import { useState } from 'react';

const CustomCheckbox = ({ label, checked, onChange } : {label : string, checked: boolean, onChange : VoidFunction}) => {
  return (
    <div className="flex items-center space-x-2">
      <div 
        onClick={onChange}
        className={`w-5 h-5 flex items-center justify-center rounded border cursor-pointer ${
          checked ? 'bg-[#118CC3] border-[#118CC3]' : 'bg-white/10 border-gray-300'
        }`}
      >
        {checked && (
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            className="h-3 w-3 text-white" 
            viewBox="0 0 20 20" 
            fill="currentColor"
          >
            <path 
              fillRule="evenodd" 
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" 
              clipRule="evenodd" 
            />
          </svg>
        )}
      </div>
      <label className="text-white text-sm cursor-pointer font-semibold" onClick={onChange}>
        {label}
      </label>
    </div>
  );
};


export default CustomCheckbox;