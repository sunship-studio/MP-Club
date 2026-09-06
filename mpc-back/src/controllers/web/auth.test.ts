/**
 * Integration test for customer accounts and magic-link sign-in.
 * Run: npx ts-node src/controllers/web/auth.test.ts
 *
 * See docs/specs/class-pass.md D16 — identity is a customer, proved by a
 * single-use emailed link, held in a server-side session.
 */
import assert from 'assert';

import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

import Customer from '../../models/Customer';
import LoginToken from '../../models/LoginToken';
import Session from '../../models/Session';

process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_placeholder';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const resend = require('../../config/resend').default;
let sent: { to: string; html: string }[] = [];
resend.emails.send = async (payload: { to: string; html: string }) => {
  sent.push(payload);
  return { data: { id: 'stub' }, error: null };
};

// eslint-disable-next-line @typescript-eslint/no-var-requires
const AuthController = require('./auth').default;
const ctrl = new AuthController();

function mockRes() {
  const r: any = { statusCode: 200, body: null, cookies: [], cleared: [] };
  r.status = (c: number) => ((r.statusCode = c), r);
  r.json = (b: any) => ((r.body = b), r);
  r.cookie = (name: string, value: string, options: any) => {
    r.cookies.push({ name, value, options });
    return r;
  };
  r.clearCookie = (name: string, options?: any) => {
    r.cleared.push({ name, options });
    return r;
  };
  return r;
}

let passed = 0;
function check(name: string, cond: boolean) {
  assert.ok(cond, `FAIL: ${name}`);
  console.log('  ✓', name);
  passed++;
}

async function call(method: string, req: Record<string, unknown> = {}) {
  const res = mockRes();
  await ctrl[method]({ body: {}, query: {}, headers: {}, ip: '203.0.113.9', ...req } as any, res);
  return res;
}

/** The token out of the most recent sign-in email. */
function tokenFromEmail(): string {
  const match = sent[sent.length - 1].html.match(/sign-in\?token=([A-Za-z0-9_-]+)/);
  assert.ok(match, 'no sign-in link in the email');
  return match![1];
}

async function requestLink(email: string, ip = '203.0.113.9') {
  return call('requestSignInLink', { body: { email }, ip });
}

async function main() {
  const mongod = await MongoMemoryServer.create();
  await mongoose.connect(mongod.getUri());
  await Promise.all([
    Customer.syncIndexes(),
    LoginToken.syncIndexes(),
    Session.syncIndexes(),
  ]);
  try {
    // 1. Asking for a link
    {
      await Customer.deleteMany({});
      await LoginToken.deleteMany({});
      sent = [];

      const res = await requestLink('Mary@Example.com');
      check('asking for a sign-in link succeeds', res.statusCode === 200);
      check('an email goes out', sent.length === 1);
      check('the email goes to the address given', sent[0].to === 'mary@example.com');
      check('the email carries a sign-in link', /sign-in\?token=/.test(sent[0].html));

      const customer = await Customer.findOne({ email: 'mary@example.com' });
      check('a customer record is created on first request', customer !== null);
    }

    // 2. An unknown email is answered identically — the endpoint must not
    //    reveal who is a customer
    {
      sent = [];
      const known = await requestLink('mary@example.com');
      const stranger = await requestLink('nobody@example.com');

      check('a stranger gets the same status as a customer',
        known.statusCode === stranger.statusCode);
      check('a stranger gets the same message as a customer',
        JSON.stringify(known.body) === JSON.stringify(stranger.body));
      check('the response never says whether the email was known',
        !/no account|not found|unknown|already/i.test(JSON.stringify(known.body)));
    }

    // 3. Signing in
    {
      await Customer.deleteMany({});
      await LoginToken.deleteMany({});
      await Session.deleteMany({});
      sent = [];

      await requestLink('signin@example.com');
      const token = tokenFromEmail();

      const res = await call('verifySignInLink', { body: { token } });
      check('a valid link signs you in', res.statusCode === 200);
      check('the response identifies the customer', res.body.email === 'signin@example.com');
      check('a session cookie is set', res.cookies.length === 1);

      const cookie = res.cookies[0];
      check('the session cookie is httpOnly, so scripts cannot read it',
        cookie.options.httpOnly === true);
      check('the session cookie is SameSite=Lax', cookie.options.sameSite === 'lax');
      check('the session cookie has an expiry', typeof cookie.options.maxAge === 'number');
      check('the raw session value is not also returned in the body',
        !JSON.stringify(res.body).includes(cookie.value));

      check('a session record exists to revoke against',
        (await Session.countDocuments({})) === 1);
      check('the session secret is not stored in the clear',
        (await Session.findOne({}))!.tokenHash !== cookie.value);
    }

    // 4. A link works once
    {
      await LoginToken.deleteMany({});
      await Session.deleteMany({});
      sent = [];
      await requestLink('onceonly@example.com');
      const token = tokenFromEmail();

      const first = await call('verifySignInLink', { body: { token } });
      const second = await call('verifySignInLink', { body: { token } });

      check('the first use of a link works', first.statusCode === 200);
      check('the second use of the same link fails', second.statusCode === 401);
      check('a reused link does not create a second session',
        (await Session.countDocuments({})) === 1);
    }

    // 5. A link goes stale
    {
      await LoginToken.deleteMany({});
      sent = [];
      await requestLink('stale@example.com');
      const token = tokenFromEmail();

      await LoginToken.updateMany(
        {},
        { $set: { expiresAt: new Date(Date.now() - 60_000) } }
      );

      const res = await call('verifySignInLink', { body: { token } });
      check('an expired link is refused', res.statusCode === 401);
      check('the refusal invites another link rather than blaming the user',
        /request a new/i.test(String(res.body.error)));
    }

    {
      const res = await call('verifySignInLink', { body: { token: 'made-up' } });
      check('an invented token is refused', res.statusCode === 401);

      const none = await call('verifySignInLink', { body: {} });
      check('verifying with no token is a 400', none.statusCode === 400);
    }

    // 6. Who am I
    {
      await LoginToken.deleteMany({});
      await Session.deleteMany({});
      sent = [];
      await requestLink('whoami@example.com');
      const signedIn = await call('verifySignInLink', { body: { token: tokenFromEmail() } });
      const sessionValue = signedIn.cookies[0].value;

      const me = await call('getCurrentCustomer', {
        headers: { cookie: `mpc_session=${sessionValue}` },
      });
      check('a session identifies the customer on a later request', me.statusCode === 200);
      check('the customer comes back', me.body.email === 'whoami@example.com');

      const anonymous = await call('getCurrentCustomer', {});
      check('no cookie means nobody is signed in', anonymous.statusCode === 200);
      check('an anonymous caller is told so plainly', anonymous.body.signedIn === false);

      const rubbish = await call('getCurrentCustomer', {
        headers: { cookie: 'mpc_session=not-a-real-session' },
      });
      check('a forged cookie signs nobody in', rubbish.body.signedIn === false);
    }

    // 7. Signing out
    {
      await Session.deleteMany({});
      sent = [];
      await requestLink('signout@example.com');
      const signedIn = await call('verifySignInLink', { body: { token: tokenFromEmail() } });
      const sessionValue = signedIn.cookies[0].value;

      const out = await call('signOut', {
        headers: { cookie: `mpc_session=${sessionValue}` },
      });
      check('signing out succeeds', out.statusCode === 200);
      check('the cookie is cleared', out.cleared.length === 1);

      const after = await call('getCurrentCustomer', {
        headers: { cookie: `mpc_session=${sessionValue}` },
      });
      check('the session stops working immediately, server-side',
        after.body.signedIn === false);
    }

    // 8. The endpoint cannot be used to flood an inbox
    {
      await LoginToken.deleteMany({});
      sent = [];
      const results = [];
      for (let i = 0; i < 8; i++) {
        results.push(await requestLink('target@example.com', '198.51.100.4'));
      }

      check('repeated requests stop sending mail', sent.length < 8);
      check('the caller is told to slow down',
        results.some((r) => r.statusCode === 429));
    }

    console.log(`\nALL ${passed} CHECKS PASSED`);
  } finally {
    await mongoose.disconnect();
    await mongod.stop();
  }
}

main().catch((e) => {
  console.error('\n', e.message || e);
  process.exit(1);
});
