'use client';

const AvailableBox = ({
  weekday,
  value,
  setValue,
}: {
  weekday: string;
  value: boolean;
  setValue: (weekday: string) => void;
}) => {
  const handleClick = () => {
    setValue(weekday);
  };

  return (
    <button
      className={`
        rounded-lg w-full justify-center items-center flex py-3 px-2
        font-semibold text-sm transition-all duration-200
        border-2
        ${
          value
            ? 'bg-[#0B79AB] text-white border-[#0B79AB] shadow-lg scale-105'
            : 'bg-white/10 text-gray-200 border-white/20 hover:bg-white/15 hover:border-white/30'
        }
      `}
      onClick={handleClick}
    >
      <p>{weekday}</p>
    </button>
  );
};

export default AvailableBox;