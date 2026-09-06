import { redirect } from 'next/navigation';

/**
 * `/cancel` used to be a form whose button had an empty click handler, posting
 * to a route the web API does not implement — it advertised membership
 * cancellation from the site header and did nothing at all.
 *
 * The profile page answers what somebody arriving here actually wants: what
 * they have, what they booked, and how to stop paying (D21). The URL stays so
 * old links and bookmarks land somewhere real.
 */
export default function CancelPage() {
  redirect('/profile');
}
