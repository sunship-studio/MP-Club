import { Request, Response } from 'express';
import { readFileSync } from 'fs';
import handlebars from 'handlebars';
import path from 'path';
import { RateLimiterMemory } from 'rate-limiter-flexible';

import resend from '../../config/resend';
import {
  SESSION_COOKIE,
  consumeLoginToken,
  createLoginToken,
  createSession,
  customerFromRequest,
  findOrCreateCustomer,
  normaliseEmail,
  readCookie,
  revokeSession,
  sessionCookieOptions,
} from '../../services/auth';
import { siteBaseUrl } from '../../services/class_pass';
import { ICustomer } from '../../models/Customer';

// Anyone can ask for a link for any address, so the endpoint is a mail cannon
// unless it is bounded. Per-address first (that is whose inbox suffers), then
// per-caller to stop one source working through a list.
const perEmail = new RateLimiterMemory({ points: 3, duration: 15 * 60 });
const perCaller = new RateLimiterMemory({ points: 20, duration: 60 * 60 });

const FROM = 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>';

export default class AuthController {
  /**
   * Email a sign-in link.
   *
   * Always answers the same way. Saying "no account found" would turn this into
   * a membership oracle: anyone could test an address and learn whether that
   * person trains here.
   */
  public async requestSignInLink(req: Request, res: Response): Promise<void> {
    const generic = {
      message: 'If we can reach you at that address, a sign-in link is on its way.',
    };

    try {
      const email = normaliseEmail(String(req.body?.email ?? ''));
      if (!email || !email.includes('@')) {
        res.status(400).json({ error: 'Please enter a valid email address' });
        return;
      }

      try {
        await perCaller.consume(req.ip ?? 'unknown');
        await perEmail.consume(email);
      } catch {
        res.status(429).json({
          error: 'Too many sign-in emails just now. Try again in a few minutes.',
        });
        return;
      }

      const customer = await findOrCreateCustomer(email);
      const token = await createLoginToken(customer);

      const templatePath = path.join(__dirname, '../../../', 'templates', 'sign_in_link.html');
      const html = handlebars.compile(readFileSync(templatePath, 'utf8'))({
        signInLink: `${siteBaseUrl()}/sign-in?token=${token}`,
      });

      await resend.emails.send({
        from: FROM,
        to: email,
        subject: 'Your sign-in link',
        html,
      });

      res.status(200).json(generic);
    } catch (error) {
      console.error('Error sending sign-in link:', error);
      // Still generic: a failure here must not become a signal either.
      res.status(200).json(generic);
    }
  }

  /** Exchange a sign-in link for a session. */
  public async verifySignInLink(req: Request, res: Response): Promise<void> {
    try {
      const token = String(req.body?.token ?? '');
      if (!token) {
        res.status(400).json({ error: 'A sign-in token is required' });
        return;
      }

      const customer = await consumeLoginToken(token);
      if (!customer) {
        res.status(401).json({
          error: 'That sign-in link has already been used or has expired. Request a new one.',
        });
        return;
      }

      const session = await createSession(customer);
      res.cookie(SESSION_COOKIE, session, sessionCookieOptions());

      // The session value goes in the cookie and nowhere else, so no script on
      // the page can read it back out of a response body.
      res.status(200).json(this.publicCustomer(customer));
    } catch (error) {
      console.error('Error verifying sign-in link:', error);
      res.status(500).json({ error: 'Could not sign you in' });
    }
  }

  /** Who is signed in, if anyone. Never an error — being anonymous is normal. */
  public async getCurrentCustomer(req: Request, res: Response): Promise<void> {
    try {
      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(200).json({ signedIn: false });
        return;
      }
      res.status(200).json({ signedIn: true, ...this.publicCustomer(customer) });
    } catch (error) {
      console.error('Error reading session:', error);
      res.status(200).json({ signedIn: false });
    }
  }

  public async signOut(req: Request, res: Response): Promise<void> {
    try {
      await revokeSession(readCookie(req, SESSION_COOKIE));
      res.clearCookie(SESSION_COOKIE, { ...sessionCookieOptions(), maxAge: undefined });
      res.status(200).json({ signedOut: true });
    } catch (error) {
      console.error('Error signing out:', error);
      res.status(500).json({ error: 'Could not sign you out' });
    }
  }

  private publicCustomer(customer: ICustomer) {
    return {
      email: customer.email,
      firstName: customer.firstName,
      lastName: customer.lastName,
    };
  }
}
