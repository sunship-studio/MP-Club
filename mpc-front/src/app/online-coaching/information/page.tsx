'use client';

import ErrorText from '@/components/waiting-list/ErrorText';
import Input from '@/components/waiting-list/input';
import AgeSlider from '@/components/waiting-list/slider';
import apiService, { DataState } from '@/services/api.service';
import { loadStripe } from '@stripe/stripe-js';
import { useState } from 'react';
import { z } from 'zod';

const stripePromise = loadStripe(
  process.env.NODE_ENV == 'production'
    ? (process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY as string)
    : (process.env.NEXT_PUBLIC_STRIPE_TEST_PUBLISHABLE_KEY as string)
);

const OnlineCoachingInformation = () => {
  const [state, setState] = useState<DataState<any>>({
    status: 'initial',
  });

  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    age: 0,
  });

  const schema = z.object({
    firstName: z.string().min(2, 'First name is required'),
    lastName: z.string().min(2, 'Last name is required'),
    email: z.string().trim().email('Invalid email address'),
    age: z.number().min(18, 'You must be at least 18 years old'),
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'range' ? parseInt(value) : value,
    }));
  };

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  const validateForm = () => {
    try {
      schema.parse(formData);
      setFormErrors({});
      return true;
    } catch (error) {
      if (error instanceof z.ZodError) {
        const newErrors: Record<string, string> = {};
        error.errors.forEach((err) => {
          if (err.path) {
            newErrors[err.path.join('.')] = err.message;
          }
        });
        setFormErrors(newErrors);
      }
      return false;
    }
  };

  async function handleSubmit() {
    const isValid = validateForm();

    if (isValid) {
      setState({ status: 'loading' });

      try {
        const response = await apiService.post<{ url: string }>(
          '/online-coaching/create-checkout-session',
          formData
        );

        if (response.url) {
          window.location.href = response.url;
        } else {
          throw new Error('No checkout URL returned');
        }
      } catch (error) {
        console.error('Checkout error:', error);
        setState({ status: 'error', error: 'Error submitting form' });
      }
    }
  }

  switch (state.status) {
    case 'initial':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          {/* Hero Section */}
          <div className="text-center mb-12">
            <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
              Sign Up for Online Coaching
            </h1>
            <p className="text-lg text-gray-200">
              Start your fitness journey with personalized coaching
            </p>
          </div>

          {/* Form Card */}
          <div className="bg-white/5 backdrop-blur rounded-lg p-8 md:p-10 shadow-xl border border-white/10">
            {/* Personal Information */}
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-white mb-6">
                Personal Information
              </h2>
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <Input
                    label="First Name"
                    handleInputChange={handleInputChange}
                    id="firstName"
                  />
                  <ErrorText error={formErrors['firstName']} />
                </div>
                <div>
                  <Input
                    label="Last Name"
                    handleInputChange={handleInputChange}
                    id="lastName"
                  />
                  <ErrorText error={formErrors['lastName']} />
                </div>
              </div>
              <div className="mt-4">
                <Input
                  label="E-mail"
                  handleInputChange={handleInputChange}
                  id="email"
                />
                <ErrorText error={formErrors['email']} />
              </div>
              <div className="mt-4">
                <AgeSlider handleInputChange={handleInputChange} />
                <ErrorText error={formErrors['age']} />
              </div>
            </div>

            {/* Pricing Info */}
            <div className="bg-[#0B79AB]/20 border border-[#0B79AB]/30 rounded-lg p-6 mb-8">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold text-white mb-2">
                    Monthly Subscription
                  </h3>
                  <p className="text-gray-200 text-sm">
                    Cancel anytime, no commitments
                  </p>
                </div>
                <div className="text-right">
                  <div className="text-4xl font-bold text-white">200€</div>
                  <div className="text-gray-300 text-sm">/month</div>
                </div>
              </div>
            </div>

            {/* Submit Button */}
            <button
              onClick={handleSubmit}
              type="submit"
              className="w-full bg-[#0B79AB] text-white py-4 rounded-lg font-bold text-lg
                         hover:bg-[#0b78ab9e] transition-all duration-200
                         shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-100
                         flex items-center justify-center gap-2"
            >
              <span>Proceed to Payment</span>
              <svg
                className="w-5 h-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 7l5 5m0 0l-5 5m5-5H6"
                />
              </svg>
            </button>

            {/* Security Badge */}
            <div className="mt-6 flex items-center justify-center gap-2 text-sm text-gray-400">
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
        </div>
      );
    case 'loading':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12 text-center">
          <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10">
            <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-[#0B79AB] mx-auto mb-4"></div>
            <h1 className="text-2xl md:text-3xl font-semibold text-white">
              Redirecting to payment...
            </h1>
          </div>
        </div>
      );
    case 'success':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          <div className="bg-white/5 backdrop-blur rounded-lg p-12 shadow-xl border border-white/10 text-center">
            <div className="mb-6">
              <svg
                className="mx-auto h-24 w-24 text-green-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h1 className="text-3xl md:text-4xl font-bold mb-4 text-white">
              Thanks for signing up!
            </h1>
            <p className="text-xl text-gray-200">
              You will receive an email when we verify your application.
            </p>
          </div>
        </div>
      );
    case 'error':
      return (
        <div className="max-w-4xl mx-auto px-8 md:px-16 py-12">
          <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-12 shadow-xl text-center">
            <div className="mb-6">
              <svg
                className="mx-auto h-24 w-24 text-red-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h1 className="text-3xl md:text-4xl font-bold mb-4 text-red-400">
              Oops! Something went wrong
            </h1>
            <p className="text-xl text-gray-200">
              Please try again or contact support if the problem persists.
            </p>
          </div>
        </div>
      );
  }
};

export default OnlineCoachingInformation;
