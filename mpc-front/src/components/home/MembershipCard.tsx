'use client';
import { useRouter } from "next/navigation"
import React from "react";

const MembershipCard = ({ title, points, option }: { title: string; points: string[]; option: number }) => {
  const router = useRouter();
  return (
    <div className={`${(option == 0) ? "bg-[#0B79AB] text-white" : "bg-white text-black"} rounded-lg p-6 shadow-lg font-inter w-full max-w-sm  md:h-65 justify-between flex flex-col space-y-4 
  `}>
      <h3 className="text-xl font-semibold mb-4 text-left">{title}</h3>
      <ul className="text-left space-y-2 mb-4 text-sm">
        {points.map((point, idx) => (
          <li key={idx}>• {point}</li>
        ))}
      </ul>
      <div className="flex justify-between text-sm items-end">
        <a href="#" className={`${option == 0 ? "" : "text-gray-700"} underline font-bold`}>Learn more</a>
        <button className={`${(option == 1) ? "bg-[#0B79AB] text-white hover:bg-[#0b78ab9e]" : "bg-white text-black hover:bg-gray-100"} cursor-pointer px-8 py-2 rounded-lg font-semibold `} onClick={
          () => {
            if (option == 0) {
              router.push("/waiting-list");
            } else {
              router.push("/online-coaching");
            }
          }
        }>Join now</button>
      </div>
    </div>
  );
}


export default MembershipCard;