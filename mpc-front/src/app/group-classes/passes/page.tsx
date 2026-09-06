'use client';

import apiService from '@/services/api.service';
import { useSession } from '@/hooks/useSession';
import MembershipPanel from '@/components/MembershipPanel';
import { CheckCircle2, Loader2, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { useEffect, useState } from 'react';

const BRAND = '#0B79AB';

interface PassProduct {
  _id: string;
  name: string;
  months: number;
  priceCents: number;
  currency: string;
  allowSubscription?: boolean;
}

const formatPrice = (cents: number) => `€${(cents / 100).toFixed(0)}`;

/** "month" / "3 months", for describing a billing period to a human. */
const termLabel = (months: number) => (months === 1 ? 'month' : `${months} months`);

export default function ClassPassesPage() {
  const { session, refresh: refreshSession } = useSession();
  const pass = session.pass;
  const [products, setProducts] = useState<PassProduct[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [buyingId, setBuyingId] = useState<string | null>(null);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (session.email) setEmail((current) => current || session.email!);
  }, [session.email]);

  useEffect(() => {
    const load = async () => {
      try {
        setProducts(await apiService.get<PassProduct[]>('/group-classes/passes'));
      } catch {
        setError('We could not load passes just now. Please try again.');
      } finally {
        setIsLoading(false);
      }
    };
    void load();
  }, []);

  // One thing on sale: a membership that renews. The choice about renewing
  // moves to after the sale, where a member can make it from their profile
  // (D20). A product that cannot recur is still sold once, so a future
  // drop-in block needs a seeded row rather than code.
  const recurringFor = (product: PassProduct) => Boolean(product.allowSubscription);

  const handleBuy = async (product: PassProduct) => {
    if (!name.trim() || !email.trim()) {
      setError('Please enter your name and email.');
      return;
    }

    const [firstName, ...rest] = name.trim().split(' ');
    setBuyingId(product._id);
    setError(null);

    try {
      const response = await apiService.post<{ url: string }>(
        '/group-classes/passes/create-checkout-session',
        {
          productId: product._id,
          firstName,
          lastName: rest.join(' '),
          email: email.trim(),
          autoRenew: recurringFor(product),
        }
      );
      if (!response.url) throw new Error('No checkout URL received');
      window.location.href = response.url;
    } catch (err: unknown) {
      const message =
        (err as { response?: { data?: { error?: string } } })?.response?.data?.error ??
        'Something went wrong starting your purchase. Please try again.';
      setError(message);
      setBuyingId(null);
    }
  };

  return (
    <div className="max-w-3xl mx-auto px-6 md:px-12 py-12">
      <Link
        href="/group-classes"
        className="inline-flex items-center gap-2 text-sm text-gray-300 hover:text-white transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Back to classes
      </Link>

      <div className="text-center mt-6 mb-10">
        <h1 className="text-4xl md:text-5xl font-bold text-white tracking-tight">
          Train as much as you like
        </h1>
        <p className="mt-4 text-lg text-gray-200">
          Every group class included, month after month. No booking fee, no
          per-class decision — just turn up.
        </p>
      </div>

      {pass && pass.recurring && (
        <div className="mb-8">
          <MembershipPanel pass={pass} onChanged={refreshSession} />
        </div>
      )}

      {pass?.valid && (
        <div className="mb-8 rounded-2xl border border-emerald-400/30 bg-emerald-400/10 p-5 text-center">
          <p className="text-emerald-200 font-semibold">
            You already have a pass, valid until {pass.validUntilDate}.
          </p>
          <p className="text-emerald-100/80 text-sm mt-1">
            You can buy another once it ends.{' '}
            <Link href="/group-classes" className="underline">
              Go book a class
            </Link>
            .
          </p>
        </div>
      )}

      {isLoading ? (
        <div className="flex justify-center py-16">
          <Loader2 className="h-10 w-10 animate-spin text-white/70" />
        </div>
      ) : products.length === 0 ? (
        <div className="rounded-2xl border border-white/10 bg-white/5 py-14 text-center">
          <p className="text-gray-200 font-medium">No passes on sale right now.</p>
          <p className="text-gray-400 text-sm mt-1">
            Drop us a message and we&apos;ll let you know when they&apos;re back.
          </p>
        </div>
      ) : (
        <div className="space-y-6">
          {products.map((product) => (
            <div
              key={product._id}
              className="rounded-2xl bg-white p-6 md:p-8 shadow-2xl ring-1 ring-black/5"
            >
              <div className="flex items-baseline justify-between gap-4 flex-wrap">
                <h2 className="text-2xl font-bold text-black">{product.name}</h2>
                <p className="text-3xl font-bold" style={{ color: BRAND }}>
                  {formatPrice(product.priceCents)}
                  <span className="text-base font-semibold text-gray-500">
                    {recurringFor(product) ? ` / ${termLabel(product.months)}` : ''}
                  </span>
                </p>
              </div>

              <ul className="mt-6 space-y-3 text-gray-700">
                {[
                  recurringFor(product)
                    ? `Every group class included, every ${termLabel(product.months)}`
                    : `Every group class included for ${termLabel(product.months)}`,
                  'No payment step when you book — just pick your slot',
                  'Cancel a class you can\'t make, so somebody else can take it',
                  ...(recurringFor(product)
                    ? ['Stop it whenever you like, from your profile']
                    : []),
                  'Same spots, first come first served',
                ].map((line) => (
                  <li key={line} className="flex items-start gap-2.5">
                    <CheckCircle2 className="h-5 w-5 shrink-0 text-emerald-500 mt-0.5" />
                    <span>{line}</span>
                  </li>
                ))}
              </ul>

              <div className="mt-7 grid gap-4 md:grid-cols-2">
                <div>
                  <label
                    htmlFor={`name-${product._id}`}
                    className="block text-sm font-semibold text-gray-700 mb-2"
                  >
                    Full Name
                  </label>
                  <input
                    id={`name-${product._id}`}
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Enter your full name"
                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:outline-none text-black placeholder:text-gray-400"
                    style={{ caretColor: BRAND }}
                  />
                </div>
                <div>
                  <label
                    htmlFor={`email-${product._id}`}
                    className="block text-sm font-semibold text-gray-700 mb-2"
                  >
                    Email Address
                  </label>
                  <input
                    id={`email-${product._id}`}
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="your.email@example.com"
                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:outline-none text-black placeholder:text-gray-400"
                    style={{ caretColor: BRAND }}
                  />
                </div>
              </div>

              <p className="mt-3 text-sm text-gray-500">
                We email your membership to this address, and it&apos;s how you sign
                in afterwards — use one you&apos;ll keep.
              </p>

              {error && (
                <p className="mt-4 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
                  {error}
                </p>
              )}

              <button
                onClick={() => handleBuy(product)}
                disabled={buyingId !== null}
                className="mt-5 w-full text-white px-8 py-4 rounded-xl font-bold text-lg shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed hover:scale-[1.01] active:scale-100"
                style={{ backgroundColor: BRAND }}
              >
                {buyingId === product._id ? (
                  <span className="flex items-center justify-center gap-2">
                    <Loader2 className="h-5 w-5 animate-spin" />
                    Redirecting to payment...
                  </span>
                ) : (
                  `${
                    recurringFor(product)
                      ? `Start membership — ${formatPrice(product.priceCents)}/${termLabel(
                          product.months
                        )}`
                      : `Buy for ${formatPrice(product.priceCents)}`
                  }`
                )}
              </button>

              <div className="mt-5 rounded-xl bg-gray-50 p-4 text-sm text-gray-600 space-y-2">
                <p>
                  <strong className="text-gray-800">How long it lasts.</strong> Your
                  pass starts the day you buy it and runs for {termLabel(product.months)}.
                  Classes dated after it ends can&apos;t be booked with it — your
                  confirmation email shows the exact date.
                </p>
                {recurringFor(product) && (
                  <p>
                    <strong className="text-gray-800">It renews on its own.</strong> We
                    charge {formatPrice(product.priceCents)} every{' '}
                    {termLabel(product.months)} until you stop it, and each payment adds
                    another {termLabel(product.months)}. Stop it any time from your
                    profile — you keep the {termLabel(product.months)} you&apos;ve paid
                    for, and it is not refunded.
                  </p>
                )}
                <p>
                  <strong className="text-gray-800">Non-refundable.</strong> Passes
                  are final: no refunds, and they can&apos;t be paused, extended or
                  transferred to somebody else.
                </p>
                <p>
                  <strong className="text-gray-800">One at a time.</strong> You can
                  hold one pass at a time. Once it ends you&apos;re free to buy
                  another.
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
