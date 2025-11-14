'use client';
import apiService from '@/services/api.service';
import { loadStripe } from '@stripe/stripe-js';
import React, { useEffect, useState } from 'react';

const stripePromise = loadStripe(
  process.env.NODE_ENV == 'production'
    ? (process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string)
    : (process.env.NEXT_PUBLIC_STRIPE_TEST_PUBLISHABLE_KEY as string)
);

interface Plan {
  id: string;
  name: string;
  excelFileUrl: string;
  listOfExercises: string[];
  stripeProductId: string;
  price: number | null;
  currency: string | null;
  priceId: string | null;
}

const WorkoutSplitPlans: React.FC = () => {
  const [plans, setPlans] = useState<Plan[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetchingPlans, setIsFetchingPlans] = useState(true);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);

  useEffect(() => {
    const fetchPlans = async () => {
      try {
        setIsFetchingPlans(true);
        const response = await apiService.get<Plan[]>('/plans');
        setPlans(response);
      } catch (error) {
        console.error('Error fetching plans:', error);
      } finally {
        setIsFetchingPlans(false);
      }
    };

    fetchPlans();
  }, []);

  return (
    <div className="container mx-auto">
      <h1 className="text-3xl font-semibold text-center mb-2 mt-6">
        Workout Split Plans
      </h1>

      {isFetchingPlans ? (
        <div className="flex justify-center items-center py-20">
          <div className="text-xl">Loading plans...</div>
        </div>
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 rounded-lg px-8 py-6">
          {plans.map((plan, index) => (
            <div
              key={plan.id}
              onClick={() => setSelectedPlan(plan)}
              className="relative h-full cursor-pointer transform transition-all duration-300 hover:scale-105 hover:shadow-2xl"
            >
              {/* White base layer */}
              <div className="absolute inset-0 bg-white z-0 rounded-xl"></div>

              {/* Colored overlay layer */}
              <div
                className={`
                absolute inset-0 z-10 rounded-xl
                bg-[#56C2F3]/${(index + 1) * 10}
              `}
              ></div>

              {/* Content layer */}
              <div className="relative z-20 p-6 text-[#002C3F] h-full flex flex-col">
                <h2 className="text-2xl font-bold mb-2">{plan.name}</h2>
                <p className="text-sm mb-4 flex-grow">
                  {plan.listOfExercises.length} exercises included
                </p>
                <div className="mt-auto flex justify-between items-center">
                  <span className="text-sm font-semibold">View Details</span>
                  <span className="text-2xl font-bold">
                    {plan.price ? `$${plan.price.toFixed(2)}` : 'N/A'}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {selectedPlan && (
        <div
          className="fixed inset-0 bg-[linear-gradient(to_bottom,#10719B,#000000bf)] bg-opacity-20 z-50 flex items-center justify-center p-4"
          onClick={() => setSelectedPlan(null)}
        >
          <div
            className="relative rounded-2xl shadow-2xl max-w-md w-full"
            onClick={(e) => e.stopPropagation()}
          >
            {/* White base layer */}
            <div className="absolute inset-0 bg-white z-0 rounded-2xl"></div>

            {/* Colored overlay layer */}
            <div className="absolute inset-0 z-10 rounded-2xl bg-[#56C2F3]/20"></div>

            {/* Content layer */}
            <div className="relative z-20 p-8 text-[#002C3F]">
              <div className="flex justify-between items-center mb-6">
                <div className="flex items-center space-x-4">
                  <span className="text-3xl font-bold">
                    {selectedPlan.price
                      ? `$${selectedPlan.price.toFixed(2)}`
                      : 'N/A'}
                  </span>
                </div>
              </div>
              <h2 className="text-3xl font-bold mb-4">{selectedPlan.name}</h2>
              <p className="mb-6 text-gray-600">
                Complete training plan with{' '}
                {selectedPlan.listOfExercises.length} exercises
              </p>
              <h3 className="text-xl font-semibold mb-4">
                Exercises Included:
              </h3>
              <ul className="space-y-3 mb-6 max-h-60 overflow-y-auto">
                {selectedPlan.listOfExercises.map((exercise, index) => (
                  <li key={index} className="flex items-center">
                    <svg
                      className="w-5 h-5 mr-2 text-[#56C2F3] flex-shrink-0"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path
                        fillRule="evenodd"
                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        clipRule="evenodd"
                      />
                    </svg>
                    <span>{exercise}</span>
                  </li>
                ))}
              </ul>
              <div className="flex space-x-4">
                <button
                  onClick={() => {
                    setSelectedPlan(null);
                    setIsLoading(false);
                  }}
                  className="w-1/2 py-3 bg-gray-100 border-1 font-semibold text-gray-800 rounded-lg hover:bg-gray-400 transition cursor-pointer"
                >
                  Close
                </button>
                {isLoading && (
                  <div className="w-1/2 py-3 bg-gray-100 border-1 font-semibold text-gray-800 rounded-lg hover:bg-gray-400 transition cursor-pointer text-center flex items-center justify-center">
                    Loading...
                  </div>
                )}
                {!isLoading && (
                  <button
                    className="w-1/2 py-3 bg-[#077fb6]  font-semibold text-white rounded-lg hover:bg-[#077fb6b3] transition cursor-pointer"
                    onClick={async () => {
                      if (!selectedPlan.priceId) {
                        alert('Price information not available');
                        return;
                      }
                      setIsLoading(true);
                      try {
                        const response = await apiService.post<{
                          url: string;
                        }>('/plans/create-checkout-session', {
                          priceId: selectedPlan.priceId,
                        });
                        await stripePromise;
                        if (response.url) {
                          window.location.href = response.url;
                        } else {
                          throw new Error('No checkout URL returned');
                        }
                      } catch (error) {
                        console.error('Checkout error:', error);
                        alert('Failed to create checkout session');
                        setIsLoading(false);
                      }
                    }}
                  >
                    Purchase Plan
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default WorkoutSplitPlans;
