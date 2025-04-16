"use client";
import AvailableBox from "@/components/waiting-list/available-box";
import CustomCheckbox from "@/components/waiting-list/Checkbox";

import AgeSlider from "@/components/waiting-list/slider";
import { number, set, z } from "zod";
import TimeDropdown from "@/components/waiting-list/TimeDropdown";
import { createContext, useContext, useState } from "react";
import ErrorText from "@/components/waiting-list/ErrorText";
import axios from "axios";
import apiService, { DataState } from "@/services/api.service";
import { loadStripe } from "@stripe/stripe-js";
import Input from "@/components/waiting-list/input";

const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string
);
type Weekday = {
  name: string;
  value: boolean;
  startTime: string;
  endTime: string;
  allDay: boolean;
};

const OnlineCoachingInformation = () => {
  const [state, setState] = useState<DataState<any>>({
    status: "initial",
  });
  // Form (all)
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    age: 0,
  });
  // Validation schema
  const schema = z.object({
    firstName: z.string().min(2, "First name is required"),
    lastName: z.string().min(2, "Last name is required"),
    email: z.string().trim().email("Invalid email address"),
    age: z.number().min(18, "You must be at least 18 years old"),
  });
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "range" ? parseInt(value) : value,
    }));
  };
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  // Validate form
  const validateForm = () => {
    try {
      // Validate weekdays

      schema.parse(formData);
    
      setFormErrors({});
      return true;
    } catch (error) {
      if (error instanceof z.ZodError) {
        const newErrors: Record<string, string> = {};
        error.errors.forEach((err) => {
          if (err.path) {
            newErrors[err.path.join(".")] = err.message;
          }
        });
        setFormErrors(newErrors);
      }
      return false;
    }
  };

  async function handleSubmit() {
    console.log("Form data", formData);
    const isValid = validateForm();

    if (isValid) {
        console.log("Form Working");
      setState({ status: "loading" });
      console.log("Form data", formData);
      try {
        const response = await apiService.post<{ sessionId: string }>(
          "/online-coaching/create-checkout-session",
          formData
        );
        const stripe = await stripePromise;
        const { sessionId } = response;
        setState({ status: "initial" });
        const result = await stripe?.redirectToCheckout({
          sessionId: sessionId,
        });
       
      
        
      } catch (error) {
        setState({ status: "error", error: "Error submitting form" });
      }
    }
  }
  switch (state.status) {
    case "initial":
      return (
        <div className="flex flex-col items-center justify-center py-8 px-6">
          <h1 className={`text-2xl md:text-3xl font-semibold mb-4 text-center`}>
            Sign up for Online Coaching
          </h1>
          <div className="flex flex-col w-full md:w-2/3 ">
            {/* Desktop Text Inputs */}
            <div className="hidden md:flex flex-col w-full space-y-2 py-2">
              <div className="flex flex-row w-full space-x-5">
                <div className="flex flex-col w-full">
                  <Input
                    label="First Name"
                    handleInputChange={handleInputChange}
                    id="firstName"
                  />
                  <ErrorText error={formErrors["firstName"]} />
                </div>
                <div className="flex flex-col w-full">
                  <Input
                    label="Last Name"
                    handleInputChange={handleInputChange}
                    id="lastName"
                  />
                  <ErrorText error={formErrors["lastName"]} />
                </div>
              </div>
              <div className="flex flex-col w-full">
                <Input
                  label="E-mail"
                  handleInputChange={handleInputChange}
                  id="email"
                />
                <ErrorText error={formErrors["email"]} />
              </div>
            </div>
            {/* Mobile Text Inputs */}
            <div className="flex flex-col md:hidden w-full">
              <Input
                label="First Name"
                handleInputChange={handleInputChange}
                id="firstName"
              />
              <ErrorText error={formErrors["firstName"]} />
              <Input
                label="Last Name"
                handleInputChange={handleInputChange}
                id="lastName"
              />
              <ErrorText error={formErrors["lastName"]} />
              <Input
                label="E-mail"
                handleInputChange={handleInputChange}
                id="email"
              />
              <ErrorText error={formErrors["email"]} />
            </div>
          </div>
          <div className="flex flex-col w-full md:w-2/3 ">
            <AgeSlider handleInputChange={handleInputChange} />
            <ErrorText error={formErrors["age"]} />
          </div>

          {/* Submit button */}
          <button
            onClick={handleSubmit}
            type="submit"
            className="flex flex-col items-center justify-center w-full md:w-2/3 py-3 bg-[#118CC3] font-semibold rounded-lg"
          >
            Procceed to payment
          </button>
        </div>
      );
    case "loading":
      return (
        <div className="flex flex-col items-center justify-center py-8 px-6">
          <h1 className={`text-2xl md:text-3xl font-semibold mb-4 text-center`}>
            Loading...
          </h1>
        </div>
      );
    case "success":
      return (
        <div className="flex flex-col items-center justify-center py-8 px-6">
          <h1 className={`text-3xl md:text-3xl font-semibold mb-4 text-center`}>
            Thanks for signing up!
          </h1>
          <img
            src="/assets/waiting-list/envelope.png"
            alt="Success"
            className="w-1/4 md:w-1/8"
          />
          <h2 className="text-xl font-semibold text-center w-full md:w-2/3 mt-4">
            You will recieve an email when I will verify your application.
          </h2>
        </div>
      );
    case "error":
      return (
        <div className="flex flex-col items-center justify-center py-8 px-6">
          <h1 className={`text-2xl md:text-3xl font-semibold mb-4 text-center`}>
            Oops! Something went wrong.
          </h1>
        </div>
      );
  }
};

export default OnlineCoachingInformation;
