'use client';

import apiClient from '@/services/api.client';
import { useCallback, useEffect, useState } from 'react';

export interface HeldPass {
  valid: boolean;
  expired: boolean;
  revoked: boolean;
  validFromDate: string;
  validUntilDate: string;
  productName: string;
  months?: number;
  /** Whether this pass was sold as a subscription at all (D17). */
  recurring?: boolean;
  autoRenew?: boolean;
  subscriptionStatus?: 'active' | 'canceling' | 'canceled';
  /** Only set while the membership is actually going to be charged again. */
  nextChargeDate?: string;
}

export interface SessionState {
  signedIn: boolean;
  firstName?: string;
  email?: string;
  pass: HeldPass | null;
}

const ANONYMOUS: SessionState = { signedIn: false, pass: null };

/**
 * Who is signed in, and what they hold.
 *
 * There is no credential in the browser to manage: the session lives in an
 * httpOnly cookie the page cannot read, so this hook only ever asks the server
 * (D16). Being anonymous is a normal state, not an error.
 */
export function useSession() {
  const [session, setSession] = useState<SessionState>(ANONYMOUS);
  const [isLoading, setIsLoading] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const { data } = await apiClient.get<SessionState>('/group-classes/passes/mine');
      setSession(data);
    } catch {
      setSession(ANONYMOUS);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const signOut = useCallback(async () => {
    try {
      await apiClient.post('/auth/sign-out');
    } finally {
      setSession(ANONYMOUS);
    }
  }, []);

  return { session, isLoading, refresh, signOut };
}

/** Ask for a sign-in link. Always resolves the same way, by design. */
export async function requestSignInLink(email: string): Promise<string> {
  try {
    const { data } = await apiClient.post<{ message: string }>('/auth/request-link', {
      email,
    });
    return data.message;
  } catch (error: unknown) {
    const response = (error as { response?: { status?: number; data?: { error?: string } } })
      .response;
    if (response?.status === 429 || response?.status === 400) {
      throw new Error(response.data?.error ?? 'Please try again shortly.');
    }
    // Anything else is answered generically too, so a failure here can't be
    // read as "that address is not a customer".
    return 'If we can reach you at that address, a sign-in link is on its way.';
  }
}

/**
 * Turn automatic renewal on or off (D19).
 *
 * The server identifies the member from the session cookie, so there is
 * nothing to send but the setting itself.
 */
export async function setAutoRenew(autoRenew: boolean): Promise<void> {
  try {
    await apiClient.post('/group-classes/passes/auto-renew', { autoRenew });
  } catch (error: unknown) {
    const message = (error as { response?: { data?: { error?: string } } }).response?.data
      ?.error;
    throw new Error(message ?? 'We could not change that just now. Please try again.');
  }
}
