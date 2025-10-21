"use client";
import apiService from "@/services/api.service";
import { loadStripe } from "@stripe/stripe-js";
import React, { useState } from "react";
const stripePromise = loadStripe(
 process.env.NODE_ENV == "production" ?  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string : process.env.NEXT_PUBLIC_STRIPE_TEST_PUBLISHABLE_KEY as string
);
const WorkoutSplitPlans: React.FC = () => {
  const plans = [
    {
      title: "Push Pull Legs Split",
      icon: (
        <img
          src="/assets/pushpull.png"
          alt="Push Pull Legs"
          className="w-14 h-14 text-[#56C2F3]"
        />
      ),
      focus: "Full Body",
      intensity: "Very High",
      overlayOpacity: "bg-[#56C2F3]/10",
      priceId: "price_1RGjVPPrBbVluHtKMSq17jrQ",
      price: 199.99,
      description:
        "Classic full-body split that provides comprehensive muscle group targeting.",
      details: [
        "Push day: Chest, shoulders, triceps",
        "Pull day: Back, biceps",
        "Leg day: Quads, hamstrings, calves",
        "Complete full-body transformation plan",
      ],
    },
    {
      title: "Upper Focused 4 Day Split",
      icon: (
        <img
          src="/assets/upper.png"
          alt="Upper Body"
          className="w-14 h-14 text-[#56C2F3]"
        />
      ),
      focus: "Upper Body",
      intensity: "High",
      overlayOpacity: "bg-[#56C2F3]/20",
      priceId: "price_1RGjVtPrBbVluHtKMS8Gj0I5",
      price: 199.99,
      description:
        "Intensive 4-day upper body split targeting muscle groups for comprehensive development.",
      details: [
        "Chest, back, shoulders, and arms focus",
        "Balanced muscle group training",
        "Strength and definition goals",
        "Comprehensive upper body development",
      ],
    },
    {
      title: "Female Lower Focused Split",
      icon: (
        <img
          src="/assets/female.png"
          alt="Lower Body"
          className="w-14 h-14 text-[#56C2F3]"
        />
      ),
      focus: "Lower Body",
      intensity: "Moderate",
      overlayOpacity: "bg-[#56C2F3]/30",
      priceId: "price_1RGjQQPrBbVluHtKOJhsfoRW",
      price: 199.99,
      description:
        "Specialized lower body workout designed specifically for female physiology and goals.",
      details: [
        "Targeted lower body muscle development",
        "Glute and leg strength focus",
        "Progressive overload approach",
        "Customized female-specific training plan",
      ],
    },

    {
      title: "Lower Focused 4 Day Split",
      icon: (
        <img
          src="/assets/lower.png"
          alt="Lower Body"
          className="w-14 h-14 text-[#56C2F3]"
        />
      ),
      focus: "Lower Body",
      intensity: "High",
      overlayOpacity: "bg-[#56C2F3]/40",
      priceId: "price_1RGjPmPrBbVluHtKAdUK720a",
      price: 199.99,
      description:
        "Comprehensive 4-day split concentrating on lower body muscle groups and strength.",
      details: [
        "4-day structured lower body workout",
        "Quad, hamstring, and calf emphasis",
        "Strength and hypertrophy training",
        "Detailed exercise progression",
      ],
    },
  ];

  let [isLoading, setIsLoading] = useState(false);

  const [selectedPlan, setSelectedPlan] = useState<(typeof plans)[0] | null>(
    null
  );

  return (
    <div className="container mx-auto">
      <h1 className="text-3xl font-semibold text-center mb-2 mt-6">
        Workout Split Plans
      </h1>

      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 rounded-lg px-8 py-6">
        {plans.map((plan) => (
          <div
            key={plan.title}
            onClick={() => setSelectedPlan(plan)}
            className="relative h-full cursor-pointer transform transition-all duration-300 hover:scale-105 hover:shadow-2xl"
          >
            {/* White base layer */}
            <div className="absolute inset-0 bg-white z-0 rounded-xl"></div>

            {/* Colored overlay layer */}
            <div
              className={`
              absolute inset-0 z-10
              ${plan.overlayOpacity}
            `}
            ></div>

            {/* Content layer */}
            <div className="relative z-20 p-6 text-[#002C3F] h-full flex flex-col">
              <div className="flex justify-between items-center mb-4">
                {plan.icon}
              </div>
              <h2 className="text-2xl font-bold mb-2">{plan.title}</h2>
              <p className="text-sm mb-4">{plan.description}</p>
              <div className="mt-auto flex justify-between items-center">
                <span className="text-sm font-semibold">
                  Focus: {plan.focus}
                </span>
                <span className="text-2xl font-bold">
                  ${plan.price.toFixed(2)}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

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
            <div
              className={`
                absolute inset-0 z-10 rounded-2xl
                ${selectedPlan.overlayOpacity}
              `}
            ></div>

            {/* Content layer */}
            <div className="relative z-20 p-8 text-[#002C3F]">
              <div className="flex justify-between items-center mb-6">
                {selectedPlan.icon}
                <div className="flex items-center space-x-4">
                  <span className="text-3xl font-bold">
                    ${selectedPlan.price.toFixed(2)}
                  </span>
                </div>
              </div>
              <h2 className="text-3xl font-bold mb-4">{selectedPlan.title}</h2>
              <p className="mb-6">{selectedPlan.description}</p>
              <h3 className="text-xl font-semibold mb-4">Key Details:</h3>
              <ul className="space-y-3 mb-6">
                {selectedPlan.details.map((detail) => (
                  <li key={detail} className="flex items-center">
                    <svg
                      className="w-5 h-5 mr-2 text-[#56C2F3]"
                      fill="currentColor"
                      viewBox="0 0 20 20"
                    >
                      <path
                        fillRule="evenodd"
                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        clipRule="evenodd"
                      />
                    </svg>
                    {detail}
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
                    setIsLoading(true);
                    const response = await apiService.post<{
                      url: string;
                    }>("/plans/create-checkout-session", {
                      priceId: selectedPlan.priceId,
                    });
                    await stripePromise;
                          if (response.url) {
        window.location.href = response.url;
      } else {
        throw new Error("No checkout URL returned");
      }



                  }}

                >
                  Purchase Plan
                </button>)}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default WorkoutSplitPlans;
