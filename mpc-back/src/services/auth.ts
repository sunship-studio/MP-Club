/**
 * Passwordless sign-in: single-use emailed links exchanged for server-side
 * sessions (D16).
 *
 * Raw secrets are never stored. What goes in the database is a SHA-256 hash,
 * so a database read yields nothing anyone can sign in with. The raw value
 * exists only in the email and in the browser's cookie.
 */
import { createHash, randomBytes, timingSafeEqual } from 'crypto';
import { Request } from 'express';

import Customer, { ICustomer } from '../models/Customer';
import LoginToken from '../models/LoginToken';
import Session from '../models/Session';

export const SESSION_COOKIE = 'mpc_session';

/** Long enough that people are not signed out mid-term on a 3-month pass. */
const SESSION_TTL_MS = 90 * 24 * 60 * 60 * 1000;

/** Short enough that a forwarded or shoulder-surfed email goes stale fast. */
const LOGIN_TOKEN_TTL_MS = 20 * 60 * 1000;

function hash(raw: string): string {
  return createHash('sha256').update(raw).digest('hex');
}

function secret(): string {
  return randomBytes(32).toString('base64url');
}

export function normaliseEmail(email: string): string {
  return email.trim().toLowerCase();
}

/**
 * The customer for an email, creating one if this is the first we've seen of
 * them. Names are filled in when known and never overwritten with nothing.
 */
export async function findOrCreateCustomer(
  email: string,
  names: { firstName?: string; lastName?: string } = {}
): Promise<ICustomer> {
  const normalised = normaliseEmail(email);

  const update: Record<string, unknown> = { email: normalised };
  if (names.firstName) update.firstName = names.firstName;
  if (names.lastName) update.lastName = names.lastName;

  return Customer.findOneAndUpdate(
    { email: normalised },
    { $set: update, $setOnInsert: { createdAt: new Date() } },
    { new: true, upsert: true }
  );
}

/** Mint a sign-in link secret. The caller emails it; we keep only its hash. */
export async function createLoginToken(customer: ICustomer): Promise<string> {
  const raw = secret();
  await LoginToken.create({
    tokenHash: hash(raw),
    customerId: customer._id,
    expiresAt: new Date(Date.now() + LOGIN_TOKEN_TTL_MS),
  });
  return raw;
}

/**
 * Spend a sign-in link, returning its customer.
 *
 * The claim is a single conditional update, so two clicks racing each other
 * cannot both succeed — a link that has been used is used.
 */
export async function consumeLoginToken(raw: string): Promise<ICustomer | null> {
  if (!raw) return null;

  const claimed = await LoginToken.findOneAndUpdate(
    { tokenHash: hash(raw), usedAt: { $exists: false }, expiresAt: { $gt: new Date() } },
    { $set: { usedAt: new Date() } },
    { new: true }
  );
  if (!claimed) return null;

  return Customer.findById(claimed.customerId);
}

/** Start a session. Returns the raw cookie value, which is never stored. */
export async function createSession(customer: ICustomer): Promise<string> {
  const raw = secret();
  await Session.create({
    tokenHash: hash(raw),
    customerId: customer._id,
    expiresAt: new Date(Date.now() + SESSION_TTL_MS),
  });
  return raw;
}

export const sessionCookieOptions = () => ({
  httpOnly: true,
  sameSite: 'lax' as const,
  // The proxy makes this first-party, so Lax is enough; Secure everywhere but
  // local development, where there is no TLS.
  secure: process.env.NODE_ENV !== 'development',
  maxAge: SESSION_TTL_MS,
  path: '/',
});

/** Read one cookie without pulling in a parser dependency. */
export function readCookie(req: Request, name: string): string | null {
  const header = req.headers?.cookie;
  if (typeof header !== 'string') return null;

  for (const part of header.split(';')) {
    const index = part.indexOf('=');
    if (index === -1) continue;
    if (part.slice(0, index).trim() === name) {
      return decodeURIComponent(part.slice(index + 1).trim());
    }
  }
  return null;
}

/**
 * Who is making this request, or null. Compares the stored hash in constant
 * time, since a lookup by hash is an equality test on a secret-derived value.
 */
export async function customerFromRequest(req: Request): Promise<ICustomer | null> {
  const raw = readCookie(req, SESSION_COOKIE);
  if (!raw) return null;

  const candidate = hash(raw);
  const session = await Session.findOne({ tokenHash: candidate });
  if (!session || session.revokedAt || session.expiresAt <= new Date()) return null;

  const a = Buffer.from(session.tokenHash);
  const b = Buffer.from(candidate);
  if (a.length !== b.length || !timingSafeEqual(a, b)) return null;

  return Customer.findById(session.customerId);
}

/** End a session server-side, so the cookie is inert even if it is kept. */
export async function revokeSession(raw: string | null): Promise<void> {
  if (!raw) return;
  await Session.updateOne({ tokenHash: hash(raw) }, { $set: { revokedAt: new Date() } });
}
