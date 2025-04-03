import { ChangeEventHandler } from "react";


const WaitingListInput = ({ label, handleInputChange, id }: { label: string, handleInputChange : ChangeEventHandler, id : string  }) => {
    return (
        <>
            <div className="flex flex-col items-center justify-center w-full h-full">

                <input
                    type={label}
                    id={id}
                    placeholder={label}
                    name={id}
                    onChange={handleInputChange}
                    className="bg-white text-black rounded-lg py-2.5 px-3 w-full my-2 focus:outline-none focus:ring-1 focus:border-transparent focus:ring-gray-300 font-medium text-sm md:text-md"
                />

            </div>
        </>
    );

}

export default WaitingListInput;