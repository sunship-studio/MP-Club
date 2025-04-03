'use client';


const AvailableBox = ({ weekday, value, setValue }: { weekday: string, value: boolean, setValue: (weekday: string) => void }) => {

    const handleClick = () => {
      
        setValue(weekday);
    };
    return (
        <button className={`${value ? "bg-white/100" : 'bg-white/50'} rounded-lg shadow-md w-full justify-center items-center flex py-2 ${value ? "text-black/90" : 'text-white'} font-semibold text-sm`} onClick={handleClick}>
            <p>{weekday}</p>
        </button>
    );
}

export default AvailableBox;