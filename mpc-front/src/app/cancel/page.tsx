"use client";
import Input from "@/components/waiting-list/input";
import apiService, { DataState } from "@/services/api.service";
import { useRouter } from "next/navigation";
import { useState } from "react";

const Cancel = () => {
  const router = useRouter();
  const [state, setState] = useState<DataState<any>>({ status: "initial" });
  let email = "";

  const handleSubmit = async () => {
    setState({ status: "loading" });
    const res = await apiService.post("/cancel", {
      email,
    });

  };
  return (
    <div className="flex flex-col items-center justify-center mt-10">
      <h1 className="text-3xl font-semibold mb-4">Cancel my membership</h1>
      <div className="flex flex-col w-full md:w-2/3 px-8">
        {" "}
        <Input
          id="email"
          label="Email"
          handleInputChange={(e: React.ChangeEvent<HTMLInputElement>) => {
            const { value } = e.target;
            email = value;
          }}
        />
        <button
          onClick={() => {}}
          className="bg-[#118CC3] w-full h-12 font-bold rounded-lg shadow-md shadow-[#118CC3]/30 text-white hover:bg-[#0f7ab5]  active:shadow-sm
    active:bg-[#0f7ab5]
    transition-all
    duration-150
    mt-2
    transform
    active:scale-99
    cursor-pointer  focus:bg-[#118CC3]
    focus:ring-opacity-50
    tap-highlight-color-transparent ease-in-out"
        >
          Cancel
        </button>
      </div>
    </div>
  );
};

export default Cancel;
