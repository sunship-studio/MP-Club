# Spec: Fixed-Term Class Pass ("3 Months Unlimited")

Status: **Phase 1 complete — design decisions resolved. Ready for Phase 2 (technical plan).**
Source: voice note from Shane, 2026-09-01 (`shane.ogg`); design review with Igor, 2026-09-02
Author: Igor K.

---

## Objective

Let a client buy a fixed-term pass — **€300 for 3 months of unlimited classes** — instead of paying €10 per class. While the pass is valid, the client books any class for free. Once the term ends, booking is refused.

**User stories**

- As a client, I buy a 3-month pass and then book classes without paying each time.
- As a client, I can cancel a class I can't attend, so I'm not holding a spot.
- As a client, when my pass has expired the site tells me clearly and offers renewal or the €10 single booking.
- As Shane (admin), I can see who holds a pass, when it expires, grant one manually, and undo mistakes.

**Success looks like:** larger up-front revenue; pass holders book with no payment step; nobody books a class dated after their pass expires.

---

## Resolved Decisions

Ten forks, settled in review on 2026-09-02. Each records what was chosen and why, so a future reader doesn't reopen them by accident.

### D1 — Entitlement is proved by an emailed token, not a typed email

Group-class booking has no login: identity today is a free-text email field on a public form. Email alone would mean a €300 product protected by a guessable string, with no payment step to make abuse self-limiting.

On purchase the client receives a link — `/group-classes?pass=<token>` — stored in `localStorage`. The token is the bearer credential; email remains a display field.

*Rejected:* real accounts (correct destination, but a login system, password reset and a booking migration — weeks, and it doesn't block us adding it later, since the pass stays keyed on email underneath).

### D2 — The server derives booker identity from the pass, ignoring client-supplied name/email

A pass booking request carries only `token`, `classId`, `timeSlot`, `occurrenceDate`. Name and email are read from the pass record.

This makes token sharing self-limiting rather than catastrophic, using machinery that already exists: `reserveSpot` rejects a second active spot with the same email for the same occurrence, so a shared link can never hold more than one spot in any class. Lending a token degrades to lending a pass. The door list shows the holder's name, so someone attending in their place is visibly wrong at check-in.

*Rejected:* trusting a client-supplied email (re-introduces the impostor problem D1 was chosen to solve); a household pass (decouples bookings from pass identity, so the duplicate guard constrains nothing and one €300 token books unlimited *people*). A genuine family pass should be a product with an explicit seat count, never an emergent side effect.

### D3 — Term is anniversary-inclusive, with month-end clamping

`validFromDate` = purchase day. `validUntilDate` = same date-of-month N months later, **inclusive**. Bought 2026-09-01, 3 months → valid through **2026-12-01**.

Where that date doesn't exist, clamp to the last day of the month: bought 2026-08-31 → 2026-11-30. Bought 2026-11-30, 3 months → 2027-02-28.

Slightly generous by a day, which is the right direction to err on a non-refundable product.

*Rejected:* calendar-month alignment (punishes late-month buyers — €300 on 28 September buys two days of September, and with no refunds Shane can't make it right); fixed 90 days (a winter pass is worth less than a summer one for the same money).

### D4 — Validity is checked against the class date, not the booking date

This is the "it would cut off" requirement. Gating on *when they click book* would let a holder spend their last valid day booking classes dated after their term ended.

Bookings already carry `occurrenceDate` as a `"YYYY-MM-DD"` string, so the term is stored the same way and compared lexicographically:

```ts
const covers = pass.validFromDate <= occurrenceDate && occurrenceDate <= pass.validUntilDate;
```

**This dodges a live bug.** The codebase mixes local dates (`toLocalDateString`) with UTC (`new Date(date).toISOString().split('T')[0]`). The frontend sends `date: selectedDate.toISOString()` where `selectedDate` is local midnight (`page.tsx:158`) — in Irish summer time that serialises to the *previous day* in UTC, which is exactly why `occurrenceDate` is sent separately. A `Date`-based term check would inherit that off-by-one precisely at the expiry boundary we're selling.

**Bounded exposure:** `page.tsx:112` renders a rolling 14-day strip, so nothing can be booked more than 13 days out. The leak without this check would be at most 13 classes, not months — still worth closing on a €300 product, and the 14-day window is a UI constant that could change.

### D5 — Passes are non-refundable; sales are final

No refund flow: no proration, no partial-term logic, no unwinding of future bookings. This removes the messiest branch in the feature.

`revoked` exists as an admin correction tool (see D9), not a refund path — it stops entitlement and moves no money.

The purchase page and confirmation email must both state the pass is non-refundable and show the exact expiry date.

> **Flag, not a blocker:** EU distance-selling rules give consumers a 14-day withdrawal right, waived for services only where the customer expressly consents to performance beginning immediately. A "sales final" checkbox at checkout is the usual handling. Worth Shane running past whoever writes his terms — policy, not engineering, and it doesn't change the build.

### D6 — Self-serve cancellation for pass bookings; no booking cap

**There is currently no way for any client to cancel a class booking.** Only online-coaching subscription cancellation exists (`online_coaching.ts:164`) and `releaseHold` for unpaid holds.

That's tolerable while a no-show costs €10 — the paid flow polices itself. A pass makes booking free, and free-to-book plus impossible-to-cancel is what turns "unlimited" into paying customers locked out of a class with empty mats in it.

So: a token-authenticated cancel endpoint that `$pull`s the confirmed spot for that pass's email and occurrence, returning it to the pool for resale at €10.

*Rejected:* a cap on concurrent future bookings. It picks a number that will eventually annoy the club's most enthusiastic member — precisely the person happiest to have bought a pass — and it doesn't help the case that matters most: someone who books four classes in good faith and then gets sick. Cancellation attacks the mechanism; a cap only limits the symptom. Revisit if hoarding is observed.

### D7 — One active pass at a time; no stacking

Buying while a pass is active is blocked (HTTP 409). `validFromDate` is therefore always the purchase day, and there is never more than one pass to evaluate.

*Accepted consequences,* both of which surface as messages to Shane rather than bugs, and both reversible later: a holder who lapses on 2 December and rebuys on the 5th loses three days; nobody can prepay before a holiday.

*Rejected:* stacking terms (queued-term math, and a holder with two passes complicates the token lookup); restart-from-purchase (silently destroys paid-for time, and with no refunds Shane can't make it right).

### D8 — A new token per pass

A returning customer's second purchase issues a fresh token; the previous one dies with its pass.

*Accepted consequence:* a lapsed customer clicking a bookmarked old link is told they have no pass, on the day they paid €300 — indistinguishable from breakage.

**Required mitigations, not optional polish:**

- A token that resolves to an expired or revoked pass returns a *specific* message — "this pass link has expired, check your most recent confirmation email" — never a generic failure.
- Opening a newer pass link overwrites any token in `localStorage`.
- The admin pass list includes **resend link**, so Shane can retrieve someone's current link without involving you.

*Rejected:* holder-scoped tokens that survive across passes (fewer support messages, but the chosen approach is simpler and the mitigations above close most of the gap).

### D9 — Revoke is an undo, and does not touch existing bookings

Revoking blocks new bookings. Classes already booked stand; Shane removes an attendee deliberately via the existing editor if he wants them gone.

**Revoke is an admin correction tool, not a disciplinary one.** The realistic triggers, in order: undoing a mistaken manual grant (wrong email, wrong Mary, double tap); a chargeback, where money has genuinely gone backwards despite the no-refund policy; clearing a test pass. Barring a client is rare in a small club and is better served by the attendee editor.

Normal end-of-life needs none of this — a pass simply stops working on the day after `validUntilDate`.

*Rejected:* cascading revoke that pulls future bookings. It deletes spots as a side effect of a status change, with no undo — spots may have been resold in the meantime. A misclicked revoke should be fixed by un-revoking, not by reconstructing someone's calendar.

### D10 — The pass covers every class, including one-offs

No `passEligible` flag in v1. "Unlimited" means unlimited.

*Accepted risk:* a guest-coach workshop could be taken entirely by pass holders for free. *Operational mitigation:* Shane sells such an event separately rather than listing it as a bookable group class. A `passEligible` boolean defaulting to `true` can be retrofitted cheaply if this ever bites.

### D11 — Pass products are seeded, not admin-editable (v1)

Pricing changes twice a year at most; a product-editor screen is the expensive half of the admin work for the least return. Products live in a `ClassPassProduct` collection, seeded by a script. Admin gets the pass *list* instead — see D12.

### D12 — Admin app: pass list only

One cubit, one list screen, one small form: who holds a pass, expiry, manual grant, revoke, resend link. Closer in size to the 523-line `group_classes.dart` than the 1055-line editor.

Shane's door list already works — pass holders appear as ordinary attendees — so nothing here blocks running a class.

Manual grant covers the failure that will certainly happen eventually: Stripe takes the money, the webhook doesn't land, and a customer who turned up has no pass. Shane fixing that in thirty seconds is worth the screen on its own.

### D13 — Web: inline card plus a thin dedicated page

A pass card on `/group-classes` (the best moment to sell a €300 pass is while someone looks at a €10 charge for the third week running) linking to `/group-classes/passes`, which carries the detail, the non-refundable terms, and the buy button. The dedicated page is mostly copy, and gives Shane a URL for WhatsApp and Instagram.

*Deliberately omitted from v1:* a per-class breakeven figure ("€300 = €X per class"). It invites arithmetic that can argue against the pass for lighter users. Shane can add it once he sees how it sells.

### D14 — Reuse the existing webhook endpoint

Pass purchases arrive at `/group_class_webhook` with `metadata.kind === 'class_pass'`. One Stripe webhook config, one signature verification path, and the booking flow underneath is untouched.

### D15 — Reject a booking with no `occurrenceDate`

The pass endpoints will **not** fall back to `new Date(date).toISOString().split('T')[0]`. Per D4 that fallback is wrong by a day in Irish summer time, and on the pass path a one-day error lands exactly on the expiry boundary.

---

## Blocking Issue in Existing Code

### B1 — `POST /web/group-classes/book` books a class for free, with no auth

`routes/group_classes.ts:11` exposes `bookGroupClass`, which writes a confirmed spot with no payment and no authentication. Anyone can `curl` it and book. It undercuts the €10 fee today, and would make a €300 pass pointless.

**Verified:** grepping `mpc-front/src`, `mpc_admin_app/lib` and `mpc_mobile_app/lib` finds **no callers**. Dead route, left over from before payment was added.

**Required:** delete the route and the `bookGroupClass` controller method. No client migration needed. Ship independently of this feature — it is a live hole today.

---

## Assumptions

Still standing, unreviewed:

1. Pass covers **group classes only** — not online coaching, not plans for sale.
2. Currency EUR; venue timezone Europe/Dublin.
3. Purchase happens on the **website** only, not the mobile apps.
4. Capacity is unchanged — pass holders compete for the same `spotsAvailable` pool as paying customers, first come first served. No reserved allocation.
5. "Unlimited" still means **one booking per class occurrence** — a pass removes payment, not the one-spot-per-person rule.

---

## Tech Stack

| Layer | Stack |
|---|---|
| Backend | Node + Express 5, TypeScript, Mongoose 8 (`mpc-back`) |
| Payments | Stripe 18 (`mode: 'payment'`), webhook at `/group_class_webhook` |
| Email | Resend, Handlebars templates in `mpc-back/templates/` |
| Web | Next.js 15.2.8, React 19, Tailwind (`mpc-front`) |
| Admin | Flutter, go_router, cubit per feature (`mpc_admin_app`) |
| Tests | `mongodb-memory-server` + `assert`, run via `ts-node` |

## Commands

```bash
# backend (mpc-back/)
npm run dev            # nodemon --exec ts-node src/app.ts
npm run build          # tsc
npm run lint           # eslint . --ext .ts
npm test               # currently runs ONE file — must be widened, see note
npx ts-node src/services/class_pass.test.ts    # new suite

# frontend (mpc-front/)
npm run dev
npm run build
```

> `npm test` runs exactly one file today (`group_class_booking.test.ts`). Two suites already exist (`admin_attendees.test.ts` is not wired in). This feature adds a third, so `test` should become a script that runs all of them — otherwise new tests silently never run in practice.

## Project Structure

```
mpc-back/src/
  models/ClassPass.ts             NEW  purchased pass instance
  models/ClassPassProduct.ts      NEW  sellable pass (name, months, price)
  services/class_pass.ts          NEW  term math + entitlement predicate
  services/class_pass.test.ts     NEW  test suite
  scripts/seed_class_passes.ts    NEW  seed the €300 / 3-month product
  controllers/web/group_class_controller.ts   EDIT  pass checkout, booking, cancel
  controllers/admin/admin_app.ts              EDIT  pass list, grant, revoke, resend
  webhook/group_class_webhook.ts              EDIT  activate pass on payment (D14)
  routes/group_classes.ts                     EDIT  new routes; delete /book (B1)
  templates/class_pass_purchase.html          NEW  purchase confirmation + pass link

mpc-front/src/app/group-classes/
  page.tsx                        EDIT  token handling, free booking, cancel, pass card
  passes/page.tsx                 NEW   buy a pass (detail + terms)
  success/page.tsx                EDIT  handle pass purchase success

mpc_admin_app/lib/
  app/models/class_pass.dart      NEW
  app/bloc/class passes/          NEW  cubit + state
  core/screens/class_passes.dart  NEW  list, grant, revoke, resend
  core/router/app_router.dart     EDIT new route
```

## Data Model

```ts
// models/ClassPassProduct.ts — what Shane sells (seeded, D11)
export interface IClassPassProduct {
  name: string;              // "3 Months Unlimited"
  months: number;            // 3
  priceCents: number;        // 30000
  currency: string;          // 'eur'
  active: boolean;           // hide without deleting
}

// models/ClassPass.ts — what a client bought
export interface IClassPass {
  email: string;             // lowercased, indexed
  firstName: string;
  lastName?: string;
  passToken: string;         // bearer credential, unique index (D1, D8)
  productId: Types.ObjectId;
  months: number;            // denormalised — product may change later
  priceCents: number;        // denormalised — price at time of sale

  status: 'pending' | 'active' | 'expired' | 'revoked';
  validFromDate: string;     // "YYYY-MM-DD" inclusive — always purchase day (D7)
  validUntilDate: string;    // "YYYY-MM-DD" inclusive (D3)

  stripeSessionId?: string;  // unique index — webhook idempotency
  stripePaymentIntentId?: string;
  purchasedAt?: Date;
  grantedByAdmin?: boolean;  // comped, no payment
  revokedAt?: Date;
  revokedReason?: string;
}
```

`status: 'expired'` is derived and never load-bearing — the authoritative check is always the date comparison, so a missed cron job cannot hand anyone a free class. Indexes: `{ passToken: 1 }` unique, `{ email: 1, validUntilDate: -1 }`, `{ stripeSessionId: 1 }` unique sparse.

## Code Style

Match `services/group_class_booking.ts`: pure exported functions, discriminated-union results instead of thrown errors for expected failures, comments explaining *why* rather than *what*.

```ts
export type PassCheck =
  | { ok: true; pass: IClassPass }
  | { ok: false; reason: 'none' | 'notyet' | 'expired' | 'revoked' };

/**
 * Entitlement is decided on the class's occurrence date, not on today. A pass
 * bought in September must not buy a December class on its last valid day —
 * that is precisely the cutoff the pass is sold on. Dates are "YYYY-MM-DD"
 * strings compared lexicographically, which sidesteps the local/UTC mismatch
 * that would otherwise land on the expiry boundary.
 */
export function passCovers(pass: IClassPass, occurrenceDate: string): PassCheck {
  if (pass.status !== 'active') return { ok: false, reason: 'revoked' };
  if (occurrenceDate < pass.validFromDate) return { ok: false, reason: 'notyet' };
  if (occurrenceDate > pass.validUntilDate) return { ok: false, reason: 'expired' };
  return { ok: true, pass };
}
```

## API Surface

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/web/group-classes/passes` | List active pass products |
| `POST` | `/web/group-classes/passes/checkout` | Stripe session; **409 if a pass is active** (D7) |
| `GET` | `/web/group-classes/passes/me?token=` | Resolve token → status, expiry, holder name |
| `POST` | `/web/group-classes/book-with-pass` | Reserve + confirm, no payment |
| `POST` | `/web/group-classes/cancel-with-pass` | Release a booked spot (D6) |
| `GET` | `/admin-app/class-passes` | Admin list, filter by status |
| `POST` | `/admin-app/class-passes` | Manually grant (comped) |
| `POST` | `/admin-app/class-passes/:id/revoke` | Revoke (undo, D9) |
| `POST` | `/admin-app/class-passes/:id/resend` | Resend pass link (D8) |
| ~~`POST`~~ | ~~`/web/group-classes/book`~~ | **DELETE — see B1** |

### Booking flow

```
paid path:  reserveSpot → Stripe checkout → webhook → confirmHold
pass path:  token → passCovers → reserveSpot → confirmHold   (same request)
```

The pass path **must** route through `reserveSpot`, never a direct `spots.push`. Its compare-and-swap on `__v` is the only thing preventing double-selling a spot, and pass holders race paying customers for the same pool.

## Testing Strategy

Follow the existing pattern exactly — standalone `ts-node` script against `mongodb-memory-server`, `assert` plus a `check()` helper, no test framework. `group_class_booking.test.ts` is the model to copy; the interesting bugs here are also concurrency and boundary bugs.

**Term maths (D3)**
1. Bought 2026-09-01, 3 months → `validUntilDate === '2026-12-01'`.
2. Month-end clamp: bought 2026-08-31 → `'2026-11-30'`, never an invalid `'2026-11-31'`.
3. Leap-adjacent clamp: bought 2026-11-30 → `'2027-02-28'`.

**Entitlement boundaries (D4)**
4. Occurrence == `validUntilDate` → allowed.
5. Occurrence == `validUntilDate` + 1 day → refused as `expired`.
6. Booking made today for an occurrence after expiry → refused, even though the pass is valid *right now*.
7. Occurrence before `validFromDate` → refused as `notyet`.
8. Revoked pass → refused. Pending pass (payment never completed) → refused.

**Booking integrity**
9. Capacity holds: 20 concurrent pass holders, `spotsAvailable: 1` → exactly 1 spot written.
10. Mixed race: pass holders and paid holds competing for one spot → exactly one wins.
11. Duplicate guard: same pass, same occurrence, twice → second refused as `dup`.
12. Same pass, next week → allowed.
13. Pass booking is stamped with the pass holder's email, not a client-supplied one (D2).

**Cancellation (D6)**
14. Cancel releases the spot and it is immediately re-bookable by someone else.
15. Cancel is scoped: it cannot release another holder's spot, or another occurrence's.

**Purchase lifecycle**
16. Webhook idempotency: the same `checkout.session.completed` delivered twice → one pass, one term, not a double-length one.
17. Checkout is refused with 409 while an active pass exists (D7).
18. A lapsed holder can buy again, and receives a *new* token (D8).

## Boundaries

**Always**
- Route every pass booking through `reserveSpot`, never a direct `spots.push`.
- Compare dates as `"YYYY-MM-DD"` strings; never `Date` objects for term checks.
- Derive booker identity from the pass, never from the request body (D2).
- Keep webhook handlers idempotent — Stripe retries.
- Run all test suites and `npm run lint` before commit.

**Ask first**
- Final price and term length before going live (see Open Questions).
- Any change to `spotsAvailable` semantics or the shared capacity pool.
- Adding a booking cap (D6 deliberately deferred it).

**Never**
- Hardcode a price in a controller — the mistake `GROUP_CLASS_PRICE_CENTS` already makes.
- Trust a client-supplied email as proof of entitlement (D1, D2).
- Let a pass bypass the per-occurrence duplicate guard or the capacity check.
- Commit Stripe webhook secrets — note they are currently **hardcoded at `webhook/group_class_webhook.ts:15-18`** and should move to env vars as separate cleanup.

## Success Criteria

- [ ] A client buys a pass, receives a confirmation email containing their pass link, and books a class with no payment step.
- [ ] The same client is refused, with a clear message, when booking a class dated after `validUntilDate`.
- [ ] A pass holder can cancel a booking and the spot immediately becomes available to others.
- [ ] Buying a second pass while one is active is refused with a clear message (D7).
- [ ] An expired pass link shows "this link has expired", not a generic error (D8).
- [ ] Concurrency test passes with pass holders and paying customers competing for the last spot.
- [ ] Replaying a Stripe webhook does not extend or duplicate a pass.
- [ ] Shane can list, grant, revoke, and resend passes from the admin app.
- [ ] Purchase page and confirmation email both state non-refundable and show the exact expiry date.
- [ ] `POST /web/group-classes/book` no longer allows an unauthenticated free booking.

## Task Breakdown (Phase 3)

Vertical slices. Each leaves the system building, tested, and committable. Correctness core first, UI last, so a wrong term rule is found on day one rather than after three screens are built on it.

- [x] **S0 — Widen `npm test` to run every suite.**
  - Acceptance: `npm test` runs `group_class_booking`, `admin_attendees`, and picks up new suites.
  - Verify: `npm test` — 25 existing checks pass.
  - Files: `mpc-back/package.json`
  - *Do this first: without it, every test below silently never runs in CI or by habit.*

- [ ] **S1 — Data model, term maths, entitlement predicate.** No HTTP, no Stripe.
  - Acceptance: `computeTerm()` and `passCovers()` implement D3, D4, D7.
  - Verify: `npx ts-node src/services/class_pass.test.ts` — term cases 1–3, entitlement 4–8.
  - Files: `models/ClassPass.ts`, `models/ClassPassProduct.ts`, `services/class_pass.ts`, `services/class_pass.test.ts`

- [ ] **S2 — Seed script and product listing.**
  - Acceptance: seeded €300/3-month product; `GET /web/group-classes/passes` returns active products.
  - Verify: run seed against local mongo, curl the endpoint.
  - Files: `scripts/seed_class_passes.ts`, `routes/group_classes.ts`, `controllers/web/group_class_controller.ts`

- [ ] **S3 — Purchase.** Stripe checkout, webhook activation, confirmation email.
  - Acceptance: paying activates a pass with a token; 409 while one is active (D7); replayed webhook is a no-op (D14).
  - Verify: test cases 16–18; Stripe CLI replay against local webhook.
  - Files: `group_class_controller.ts`, `webhook/group_class_webhook.ts`, `templates/class_pass_purchase.html`, `routes/group_classes.ts`

- [ ] **S4 — Booking with a pass.** The risky slice: it races the paid path for spots.
  - Acceptance: `POST /book-with-pass` reserves + confirms in one request via `reserveSpot`; identity from the pass (D2); rejects missing `occurrenceDate` (D15).
  - Verify: test cases 9–13, especially the mixed pass/paid race.
  - Files: `group_class_controller.ts`, `routes/group_classes.ts`, `services/class_pass.ts`

- [ ] **S5 — Cancellation** (D6).
  - Acceptance: token-authenticated cancel releases the spot for resale; cannot touch another holder's or occurrence's spot.
  - Verify: test cases 14–15.
  - Files: `group_class_controller.ts`, `routes/group_classes.ts`

- [ ] **S6 — Website** (D13).
  - Acceptance: pass card on `/group-classes`; `/group-classes/passes` with terms and buy button; token read from URL and `localStorage`; free booking; expired-link message (D8); cancel control.
  - Verify: manual end-to-end — buy, book free, cancel, let a pass expire in test data and confirm refusal.
  - Files: `mpc-front/src/app/group-classes/page.tsx`, `passes/page.tsx`, `success/page.tsx`

- [ ] **S7 — Admin app** (D12).
  - Acceptance: list passes with expiry; manual grant; revoke; resend link.
  - Verify: manual against staging backend.
  - Files: `mpc-back` admin endpoints, then `mpc_admin_app` model, cubit, screen, route.

**Done separately:** B1 route deletion — branch `fix/remove-unauthenticated-booking-route`, commit `e225dadd`.

## Open Questions

1. **Price and term confirmation.** €300 / 3 months came from Shane thinking aloud ("let's just say €300"). Needs confirming before launch — though it's seeded data, so changing it is a two-minute job, not a code change.
2. **Expiry reminder email.** "Your pass expires in 7 days" would drive renewals, but there is **no scheduler in the backend today** — no cron, no job runner. That's new infrastructure, so it's out of v1 scope unless Shane rates it highly.
3. **Ship order.** B1 (the free-booking hole) is independent and ready now. Ship it immediately, or bundle it with this feature?
