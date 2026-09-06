'use client';
import { useRouter } from 'next/navigation';

const BuyButton = () => {
  const router = useRouter();

  return (
    <div className="bg-white rounded-lg shadow-xl p-6 md:p-8 h-full flex flex-col">
      <h2 className="text-2xl md:text-3xl font-bold mb-4 text-black">
        Pricing
      </h2>

      {/* Price Display */}
      <div className="mb-6">
        <div className="flex items-baseline gap-2 mb-2">
          <span className="text-5xl font-bold text-[#0B79AB]">200€</span>
          <span className="text-xl text-gray-600">/month</span>
        </div>
        <p className="text-sm text-gray-600">Cancel anytime, no commitments</p>
      </div>

      {/* Features List */}
      <div className="mb-6 space-y-2 flex-grow">
        <div className="flex items-center text-gray-700">
          <svg
            className="w-5 h-5 text-green-500 mr-2"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fillRule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clipRule="evenodd"
            />
          </svg>
          Unlimited access
        </div>
        <div className="flex items-center text-gray-700">
          <svg
            className="w-5 h-5 text-green-500 mr-2"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fillRule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clipRule="evenodd"
            />
          </svg>
          1-on-1 coaching support
        </div>
        <div className="flex items-center text-gray-700">
          <svg
            className="w-5 h-5 text-green-500 mr-2"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fillRule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clipRule="evenodd"
            />
          </svg>
          Custom meal programs
        </div>
      </div>

      {/* CTA Button */}
      <button
        onClick={() => {
          router.push('/online-coaching/information');
        }}
        className="bg-[#0B79AB] w-full py-4 font-bold rounded-lg shadow-lg text-white hover:bg-[#0b78ab9e] active:shadow-md transition-all duration-150 transform hover:scale-105 active:scale-100 cursor-pointer"
      >
        Start Now
      </button>

      {/* Stripe Badge */}
      <div className="mt-4 flex items-center justify-center gap-2 text-sm text-gray-500">
        <svg
          className="w-4 h-4"
          fill="currentColor"
          viewBox="0 0 20 20"
        >
          <path
            fillRule="evenodd"
            d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
            clipRule="evenodd"
          />
        </svg>
        Secure payment via Stripe
      </div>
    </div>
  );
};

export default BuyButton;
