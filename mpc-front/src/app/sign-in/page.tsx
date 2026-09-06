'use client';

import apiClient from '@/services/api.client';
import { requestSignInLink } from '@/hooks/useSession';
import { CheckCircle2, Loader2, Mail } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

const BRAND = '#0B79AB';

type Phase = 'form' | 'sending' | 'sent' | 'verifying' | 'failed';

export default function SignInPage() {
  const router = useRouter();
  const [phase, setPhase] = useState<Phase>('form');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState<string | null>(null);

  // A token in the URL means they arrived from an email: exchange it for a
  // session and get them where they were going.
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');
    if (!token) return;

    // Only ever a path on this site: an open redirect turns a sign-in link
    // into a way to bounce somebody somewhere else.
    const next = params.get('next');
    const destination = next && /^\/[^/\\]/.test(next) ? next : '/group-classes';

    setPhase('verifying');
    apiClient
      .post('/auth/verify', { token })
      .then(() => router.replace(destination))
      .catch((error) => {
        setPhase('failed');
        setMessage(
          error?.response?.data?.error ??
            'That sign-in link did not work. Ask for a new one below.'
        );
      });
  }, [router]);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!email.trim()) return;

    setPhase('sending');
    try {
      const result = await requestSignInLink(email.trim());
      setMessage(result);
      setPhase('sent');
    } catch (error) {
      setMessage((error as Error).message);
      setPhase('form');
    }
  };

  if (phase === 'verifying') {
    return (
      <div className="max-w-md mx-auto px-6 py-24 text-center">
        <Loader2 className="mx-auto h-10 w-10 animate-spin text-white/70" />
        <p className="mt-4 text-gray-200">Signing you in…</p>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto px-6 py-16">
      <div className="rounded-2xl bg-white p-8 shadow-2xl ring-1 ring-black/5">
        {phase === 'sent' ? (
          <div className="text-center">
            <CheckCircle2 className="mx-auto h-12 w-12 text-green-500" />
            <h1 className="mt-4 text-2xl font-bold text-black">Check your email</h1>
            <p className="mt-3 text-gray-600">{message}</p>
            <p className="mt-4 text-sm text-gray-500">
              The link works once and lasts 20 minutes. You can ask for another any
              time — there is nothing to remember and nothing to lose.
            </p>
            <button
              onClick={() => setPhase('form')}
              className="mt-6 text-sm underline text-gray-600 hover:text-black"
            >
              Use a different email
            </button>
          </div>
        ) : (
          <>
            <h1 className="text-2xl font-bold text-black">Sign in</h1>
            <p className="mt-2 text-gray-600">
              Enter your email and we&apos;ll send you a link. No password to
              remember.
            </p>

            {phase === 'failed' && message && (
              <p className="mt-4 rounded-xl bg-amber-50 px-4 py-3 text-sm text-amber-800">
                {message}
              </p>
            )}

            <form onSubmit={handleSubmit} className="mt-6">
              <label
                htmlFor="signin-email"
                className="block text-sm font-semibold text-gray-700 mb-2"
              >
                Email Address
              </label>
              <input
                id="signin-email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your.email@example.com"
                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:outline-none text-black placeholder:text-gray-400"
                style={{ caretColor: BRAND }}
              />

              <button
                type="submit"
                disabled={phase === 'sending'}
                className="mt-5 w-full text-white px-8 py-4 rounded-xl font-bold text-lg shadow-lg disabled:opacity-50"
                style={{ backgroundColor: BRAND }}
              >
                {phase === 'sending' ? (
                  <span className="flex items-center justify-center gap-2">
                    <Loader2 className="h-5 w-5 animate-spin" /> Sending…
                  </span>
                ) : (
                  <span className="flex items-center justify-center gap-2">
                    <Mail className="h-5 w-5" /> Email me a sign-in link
                  </span>
                )}
              </button>
            </form>

            <p className="mt-5 text-sm text-gray-500">
              Signing in is only needed to use a class pass. Booking a single class
              for €10 needs no account.
            </p>
          </>
        )}
      </div>
    </div>
  );
}
