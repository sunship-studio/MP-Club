'use client';

import apiClient from '@/services/api.client';
import { useCallback, useEffect, useState } from 'react';

export interface Booking {
  classId: string;
  title: string;
  timeSlot: string;
  occurrenceDate: string;
  durationMinutes: number;
  /** Whether a pass paid for it — only those are self-cancellable (D22). */
  bookedWithPass: boolean;
}

interface BookingsState {
  upcoming: Booking[];
  past: Booking[];
}

const EMPTY: BookingsState = { upcoming: [], past: [] };

/**
 * What the signed-in member has booked. The server decides whose bookings
 * these are from the session cookie, so there is nothing to pass in.
 */
export function useMyBookings() {
  const [bookings, setBookings] = useState<BookingsState>(EMPTY);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    try {
      const { data } = await apiClient.get<BookingsState>('/group-classes/my-bookings');
      setBookings(data);
      setError(null);
    } catch (e: unknown) {
      const status = (e as { response?: { status?: number } }).response?.status;
      // Being signed out is the page's problem to handle, not an error to show.
      if (status !== 401) setError('We could not load your classes just now.');
      setBookings(EMPTY);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  return { bookings, isLoading, error, refresh };
}

/** Give up a booked spot. Only bookings a pass paid for may be cancelled (D22). */
export async function cancelBooking(booking: Booking): Promise<void> {
  try {
    await apiClient.post('/group-classes/cancel-with-pass', {
      classId: booking.classId,
      timeSlot: booking.timeSlot,
      occurrenceDate: booking.occurrenceDate,
    });
  } catch (error: unknown) {
    const message = (error as { response?: { data?: { error?: string } } }).response?.data
      ?.error;
    throw new Error(message ?? 'We could not cancel that just now. Please try again.');
  }
}
