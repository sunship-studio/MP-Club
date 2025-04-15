"use client";
import apiService from "@/services/api.service";
import { loadStripe } from "@stripe/stripe-js";
import { useRouter } from "next/navigation";
const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string
);

const BuyButton = () => {
  const router = useRouter();

  return (
    <div className="flex flex-col w-full">
      <span className="hidden md:block text-lg font-medium text-right mb-6">
        Unlock personalized coaching, exclusive content, custom meal programs
        and more. <br />
        <p className="font-bold">Start your transformation today!</p>
      </span>
      <div className="flex flex-row w-full mb-4 justify-between">
        <img src="/assets/online-coaching/stripe.png" className="w-25 h-auto" />

        <p className="text-lg font-bold">200€/month</p>
      </div>
      <button
        onClick={() => {
          router.push("/online-coaching/information");
        }}
        className="bg-[#118CC3] w-full h-12 font-bold rounded-lg shadow-md shadow-[#118CC3]/30 text-white hover:bg-[#0f7ab5]  active:shadow-sm
    active:bg-[#0f7ab5]
    transition-all
    duration-150
    transform
    active:scale-99
    cursor-pointer  focus:bg-[#118CC3]
    focus:ring-opacity-50
    tap-highlight-color-transparent ease-in-out"
      >
        Start now
      </button>
    </div>
  );
};

export default BuyButton;
