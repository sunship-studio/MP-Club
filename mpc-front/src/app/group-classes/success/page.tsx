'use client';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';

function SuccessContent() {
  const searchParams = useSearchParams();
  const sessionId = searchParams.get('session_id');

  return (
    <div className="max-w-2xl mx-auto px-8 py-16 text-center">
      <div className="bg-white rounded-2xl p-12 shadow-2xl">
        {/* Success Icon */}
        <div className="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-8">
          <svg
            className="w-12 h-12 text-green-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          Booking Confirmed! 🎉
        </h1>

        <p className="text-lg text-gray-600 mb-8">
          Thank you for your payment. Your group class booking has been
          confirmed. Check your email for the booking details.
        </p>

        <div className="bg-gray-50 rounded-lg p-6 mb-8">
          <h2 className="font-semibold text-gray-900 mb-2">
            What&apos;s next?
          </h2>
          <ul className="text-left text-gray-600 space-y-2">
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-1">✓</span>
              <span>
                You&apos;ll receive a confirmation email with all the details
              </span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-1">✓</span>
              <span>Arrive 10 minutes before your scheduled class time</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-1">✓</span>
              <span>Bring comfortable workout clothes and water</span>
            </li>
          </ul>
        </div>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            href="/group-classes"
            className="inline-block bg-[#0B79AB] text-white px-8 py-3 rounded-lg font-semibold hover:bg-[#0b78ab9e] transition-all"
          >
            Book Another Class
          </Link>
          <Link
            href="/"
            className="inline-block bg-gray-200 text-gray-800 px-8 py-3 rounded-lg font-semibold hover:bg-gray-300 transition-all"
          >
            Back to Home
          </Link>
        </div>

        {sessionId && (
          <p className="text-xs text-gray-400 mt-8">
            Transaction ID: {sessionId}
          </p>
        )}
      </div>
    </div>
  );
}

export default function GroupClassSuccessPage() {
  return (
    <Suspense
      fallback={
        <div className="max-w-2xl mx-auto px-8 py-16 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#0B79AB] mx-auto"></div>
        </div>
      }
    >
      <SuccessContent />
    </Suspense>
  );
}
