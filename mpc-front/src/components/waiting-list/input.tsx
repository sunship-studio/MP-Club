import { ChangeEventHandler } from 'react';

const Input = ({
  label,
  handleInputChange,
  id,
}: {
  label: string;
  handleInputChange: ChangeEventHandler;
  id: string;
}) => {
  return (
    <div className="flex flex-col w-full">
      <label
        htmlFor={id}
        className="text-sm font-semibold text-gray-200 mb-2"
      >
        {label}
      </label>
      <input
        type={id === 'email' ? 'email' : 'text'}
        id={id}
        placeholder={`Enter your ${label.toLowerCase()}`}
        name={id}
        onChange={handleInputChange}
        className="bg-white/10 backdrop-blur text-gray-900 rounded-lg py-3 px-4 w-full
                   border border-white/20
                   focus:outline-none focus:ring-2 focus:ring-[#0B79AB] focus:border-transparent
                   placeholder:text-gray-500
                   transition-all duration-200
                   hover:bg-white/15
                   font-medium text-sm md:text-base"
      />
    </div>
  );
};

export default Input;