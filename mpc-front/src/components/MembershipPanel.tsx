'use client';

import { HeldPass, setAutoRenew } from '@/hooks/useSession';
import { Loader2, RefreshCw, XCircle } from 'lucide-react';
import { useState } from 'react';

const BRAND = '#0B79AB';

/**
 * The renewal switch a member sees once they hold a recurring membership (D19).
 *
 * Renders nothing for a one-off pass: there is no renewal to manage, and a
 * disabled control would only raise a question the page cannot answer.
 */
export default function MembershipPanel({
  pass,
  onChanged,
}: {
  pass: HeldPass;
  onChanged: () => void | Promise<void>;
}) {
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!pass.recurring) return null;

  const ended = pass.subscriptionStatus === 'canceled';
  const renewing = Boolean(pass.autoRenew) && !ended;

  const change = async (next: boolean) => {
    setIsSaving(true);
    setError(null);
    try {
      await setAutoRenew(next);
      await onChanged();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Please try again.');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="rounded-2xl border border-white/10 bg-white/5 p-5">
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <p className="font-semibold text-white">{pass.productName}</p>
          {renewing ? (
            <p className="mt-1 text-sm text-gray-300">
              Renews automatically
              {pass.nextChargeDate ? ` on ${pass.nextChargeDate}` : ''}. You&apos;ll be
              charged again and your pass extends from {pass.validUntilDate}.
            </p>
          ) : ended ? (
            <p className="mt-1 text-sm text-gray-300">
              Your membership has ended. Buy a new one whenever you want to come back.
            </p>
          ) : (
            <p className="mt-1 text-sm text-gray-300">
              Automatic payments are off. Your pass still works until{' '}
              {pass.validUntilDate}, then it stops.
            </p>
          )}
        </div>

        {!ended && (
          <button
            onClick={() => change(!renewing)}
            disabled={isSaving}
            className="inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold text-white transition-colors disabled:opacity-50"
            style={{ backgroundColor: renewing ? 'transparent' : BRAND }}
          >
            {isSaving ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : renewing ? (
              <XCircle className="h-4 w-4" />
            ) : (
              <RefreshCw className="h-4 w-4" />
            )}
            {renewing ? 'Turn off automatic payments' : 'Turn automatic payments back on'}
          </button>
        )}
      </div>

      {renewing && (
        <p className="mt-3 text-xs text-gray-400">
          Turning it off keeps the term you&apos;ve already paid for. Nothing is
          refunded for the current one.
        </p>
      )}

      {error && (
        <p className="mt-3 rounded-lg bg-red-500/10 px-3 py-2 text-sm text-red-300">{error}</p>
      )}
    </div>
  );
}
