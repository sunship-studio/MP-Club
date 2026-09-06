'use client';
import apiService from '@/services/api.service';
import { loadStripe } from '@stripe/stripe-js';
import React, { useEffect, useState } from 'react';

const stripePromise = loadStripe(
  process.env.NODE_ENV == 'development'
    ? (process.env.NEXT_PUBLIC_STRIPE_TEST_PUBLISHABLE_KEY as string)
    : (process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string)
);

interface Plan {
  id: string;
  name: string;
  excelFileUrl: string;
  days: TrainingDay[];
  stripeProductId: string;
  price: number | null;
  currency: string | null;
  priceId: string | null;
}

interface TrainingSet {
  reps: number;
  rir: number;
  weight: number;
}

interface Exercise {
  bodyParts: string[];
  exerciseId: string;
  minutes: number;
  videoUrl?: string;
  seconds: number;
  sets: TrainingSet[];
  name: string;
}

interface TrainingDay {
  name: string;
  exercises: Exercise[];
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
    <div className="max-w-7xl mx-auto px-8 md:px-16 py-12">
      {/* Hero Section */}
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
          Training Plans
        </h1>
        <p className="text-lg text-gray-200 max-w-3xl mx-auto">
          Choose from our expertly crafted workout split plans designed to help
          you reach your fitness goals
        </p>
      </div>

      {isFetchingPlans ? (
        <div className="flex justify-center items-center py-20">
          <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10">
            <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-[#0B79AB] mx-auto mb-4"></div>
            <p className="text-xl text-white">Loading plans...</p>
          </div>
        </div>
      ) : plans.length === 0 ? (
        <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10 text-center">
          <svg
            className="w-24 h-24 text-gray-400 mx-auto mb-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          <h3 className="text-2xl font-bold text-white mb-2">
            No Plans Available
          </h3>
          <p className="text-gray-300 max-w-md mx-auto">
            There are currently no training plans available. Please check back
            later.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {plans.map((plan, index) => (
            <div
              key={plan.id}
              onClick={() => setSelectedPlan(plan)}
              className="bg-white rounded-lg shadow-xl p-6 cursor-pointer
                         transform transition-all duration-300 hover:scale-105 hover:shadow-2xl
                         border-2 border-transparent hover:border-[#0B79AB]
                         flex flex-col h-full"
            >
              {/* Plan Header */}
              <div className="mb-4">
                <h2 className="text-2xl font-bold text-gray-900 mb-2">
                  {plan.name}
                </h2>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <svg
                    className="w-4 h-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                    />
                  </svg>
                  <span>{plan.days.length} training days</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600 mt-1">
                  <svg
                    className="w-4 h-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                    />
                  </svg>
                  <span>
                    {plan.days.reduce(
                      (total, day) => total + day.exercises.length,
                      0
                    )}{' '}
                    exercises
                  </span>
                </div>
              </div>

              {/* Body Parts Preview */}
              <div className="mb-4 flex-grow">
                <div className="flex flex-wrap gap-2">
                  {Array.from(
                    new Set(
                      plan.days
                        .flatMap((day) => day.exercises)
                        .flatMap((ex) => ex.bodyParts)
                    )
                  )
                    .slice(0, 4)
                    .map((part, idx) => (
                      <span
                        key={idx}
                        className="text-xs bg-[#0B79AB]/10 text-[#0B79AB] px-3 py-1 rounded-full font-medium"
                      >
                        {part}
                      </span>
                    ))}
                  {Array.from(
                    new Set(
                      plan.days
                        .flatMap((day) => day.exercises)
                        .flatMap((ex) => ex.bodyParts)
                    )
                  ).length > 4 && (
                    <span className="text-xs bg-gray-100 text-gray-600 px-3 py-1 rounded-full font-medium">
                      +
                      {Array.from(
                        new Set(
                          plan.days
                            .flatMap((day) => day.exercises)
                            .flatMap((ex) => ex.bodyParts)
                        )
                      ).length - 4}{' '}
                      more
                    </span>
                  )}
                </div>
              </div>

              {/* Price & CTA */}
              <div className="mt-auto pt-4 border-t border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-3xl font-bold text-[#0B79AB]">
                      {plan.price ? `€${plan.price.toFixed(2)}` : 'N/A'}
                    </div>
                    <div className="text-xs text-gray-600">one-time payment</div>
                  </div>
                  <button className="bg-[#0B79AB] text-white px-6 py-3 rounded-lg font-semibold hover:bg-[#0b78ab9e] transition-all">
                    View Plan
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Plan Details Modal */}
      {selectedPlan && (
        <div
          className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setSelectedPlan(null)}
        >
          <div
            className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b border-gray-200 p-6 rounded-t-2xl z-10">
              <div className="flex justify-between items-start">
                <div>
                  <h2 className="text-3xl font-bold text-gray-900 mb-2">
                    {selectedPlan.name}
                  </h2>
                  <div className="flex items-center gap-4">
                    <span className="text-4xl font-bold text-[#0B79AB]">
                      {selectedPlan.price
                        ? `€${selectedPlan.price.toFixed(2)}`
                        : 'N/A'}
                    </span>
                    <span className="text-sm text-gray-600">
                      one-time payment
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setSelectedPlan(null);
                    setIsLoading(false);
                  }}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg
                    className="w-8 h-8"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              {/* Plan Overview */}
              <div className="bg-[#0B79AB]/5 rounded-lg p-6 mb-6">
                <h3 className="text-xl font-bold text-gray-900 mb-4">
                  Plan Overview
                </h3>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  <div className="bg-white rounded-lg p-4 text-center">
                    <div className="text-3xl font-bold text-[#0B79AB]">
                      {selectedPlan.days.length}
                    </div>
                    <div className="text-sm text-gray-600 mt-1">
                      Training Days
                    </div>
                  </div>
                  <div className="bg-white rounded-lg p-4 text-center">
                    <div className="text-3xl font-bold text-[#0B79AB]">
                      {selectedPlan.days.reduce(
                        (total, day) => total + day.exercises.length,
                        0
                      )}
                    </div>
                    <div className="text-sm text-gray-600 mt-1">
                      Total Exercises
                    </div>
                  </div>
                  <div className="bg-white rounded-lg p-4 text-center col-span-2 md:col-span-1">
                    <div className="text-3xl font-bold text-[#0B79AB]">
                      {Array.from(
                        new Set(
                          selectedPlan.days
                            .flatMap((day) => day.exercises)
                            .flatMap((ex) => ex.bodyParts)
                        )
                      ).length}
                    </div>
                    <div className="text-sm text-gray-600 mt-1">
                      Body Parts
                    </div>
                  </div>
                </div>
              </div>

              {/* Training Split */}
              <div className="mb-6">
                <h3 className="text-xl font-bold text-gray-900 mb-4">
                  Training Split
                </h3>
                <div className="space-y-4">
                  {selectedPlan.days.map((day, dayIndex) => {
                    const bodyParts = Array.from(
                      new Set(
                        day.exercises.flatMap((exercise) => exercise.bodyParts)
                      )
                    );

                    return (
                      <div
                        key={dayIndex}
                        className="bg-gray-50 rounded-lg p-5 border border-gray-200 hover:border-[#0B79AB] transition-colors"
                      >
                        <div className="flex justify-between items-start mb-3">
                          <h4 className="font-bold text-lg text-[#0B79AB]">
                            {day.name}
                          </h4>
                          <span className="bg-[#0B79AB]/10 text-[#0B79AB] px-3 py-1 rounded-full text-xs font-semibold">
                            {day.exercises.length} exercises
                          </span>
                        </div>
                        {bodyParts.length > 0 && (
                          <div className="flex flex-wrap gap-2">
                            {bodyParts.map((part, idx) => (
                              <span
                                key={idx}
                                className="text-sm bg-white text-gray-700 px-3 py-1 rounded-full font-medium border border-gray-200"
                              >
                                {part}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="sticky bottom-0 bg-white border-t border-gray-200 p-6 rounded-b-2xl">
              <div className="flex flex-col sm:flex-row gap-3">
                <button
                  onClick={() => {
                    setSelectedPlan(null);
                    setIsLoading(false);
                  }}
                  className="flex-1 py-3 bg-gray-100 font-semibold text-gray-700 rounded-lg hover:bg-gray-200 transition"
                >
                  Close
                </button>
                {isLoading ? (
                  <div className="flex-1 py-3 bg-[#0B79AB]/50 font-semibold text-white rounded-lg flex items-center justify-center">
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                    Processing...
                  </div>
                ) : (
                  <button
                    className="flex-1 py-3 bg-[#0B79AB] font-semibold text-white rounded-lg hover:bg-[#0b78ab9e] transition transform hover:scale-105 active:scale-100"
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
