'use client';

import Link from 'next/link';
import { CheckCircle2, Mail } from 'lucide-react';

const BRAND = '#0B79AB';

export default function PassPurchaseSuccessPage() {
  return (
    <div className="max-w-2xl mx-auto px-8 py-16 text-center">
      <div className="bg-white rounded-2xl p-10 md:p-12 shadow-2xl">
        <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-8">
          <CheckCircle2 className="w-11 h-11 text-green-500" />
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          Your pass is active 🎉
        </h1>

        <p className="text-lg text-gray-600 mb-8">
          Payment received. We&apos;ve emailed you your pass link — that link is
          how we know the pass is yours, so keep the email.
        </p>

        <div className="rounded-xl bg-gray-50 p-6 mb-8 text-left">
          <h2 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
            <Mail className="h-5 w-5" style={{ color: BRAND }} />
            What&apos;s next
          </h2>
          <ul className="text-gray-600 space-y-2.5">
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-0.5">✓</span>
              <span>
                Open the link in that email — your browser remembers it, so you
                only need to do this once.
              </span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-0.5">✓</span>
              <span>
                Book any group class with no payment step, right up to your
                expiry date (it&apos;s in the email).
              </span>
            </li>
            <li className="flex items-start gap-2">
              <span className="text-green-500 mt-0.5">✓</span>
              <span>
                Can&apos;t make a class you booked? Cancel it so somebody else can
                take the spot.
              </span>
            </li>
          </ul>
        </div>

        <p className="text-sm text-gray-500 mb-8">
          Email not arrived in a few minutes? Check spam, then get in touch and
          we&apos;ll resend your link.
        </p>

        <Link
          href="/group-classes"
          className="inline-block w-full text-white px-8 py-4 rounded-xl font-bold text-lg shadow-lg transition-all hover:scale-[1.01]"
          style={{ backgroundColor: BRAND }}
        >
          Book your first class
        </Link>
      </div>
    </div>
  );
}
