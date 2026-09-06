import axios from 'axios';

/**
 * Credentialed API client.
 *
 * Talks to this site's own origin, which proxies to the API, so the session
 * cookie is first-party and survives Safari's tracking prevention (D16).
 * Anonymous reads still use `api.service.ts` and go to the API directly —
 * they carry no session and gain nothing from the extra hop.
 */
const apiClient = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
  withCredentials: true,
});

export default apiClient;
