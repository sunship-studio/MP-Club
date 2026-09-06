import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

import resend from '../../config/resend';
import stripe from '../../config/stripe';
import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import GroupClass from '../../models/GroupClass';
import {
  activatePass,
  applyRenewalInvoice,
  findActivePassForEmail,
  isPassDateString,
  passCovers,
  siteBaseUrl,
  venueToday,
} from '../../services/class_pass';
import { customerFromRequest, findOrCreateCustomer } from '../../services/auth';
import { sendPassLinkEmail, sendPassRenewalEmail } from '../../services/class_pass_email';
import {
  confirmHold,
  isSpotActive,
  releaseHold,
  reserveSpot,
  slotMinutes,
  venueClockMinutes,
} from '../../services/group_class_booking';

// Pending reservation lifetime. Must outlast the Stripe checkout window so a
// session that is still payable always has a live hold backing it.
const HOLD_TTL_MS = 35 * 60 * 1000; // 35 min (Stripe session expires at 30)
const STRIPE_SESSION_TTL_S = 30 * 60; // Stripe minimum is 30 min

// Price for group class booking in cents (€10 = 1000 cents)
const GROUP_CLASS_PRICE_CENTS = 1000;

/** "month" / "3 months", for describing a billing period to a human. */
function termLabel(months: number): string {
  return months === 1 ? 'month' : `${months} months`;
}

export default class GroupClassController {
  public async getGroupClasses(req: Request, res: Response): Promise<void> {
    try {
      const groupClasses = await GroupClass.find();
      res.status(200).json(groupClasses);
    } catch (error) {
      console.error('Error fetching group classes:', error);
      res.status(500).json({ error: 'Failed to fetch group classes' });
    }
  }

  /**
   * The class passes currently on sale. Returns an array so the site renders
   * whatever comes back rather than assuming a single product (D11).
   */
  public async getPassProducts(req: Request, res: Response): Promise<void> {
    try {
      const products = await ClassPassProduct.find({ active: true }).lean();
      res.status(200).json(products);
    } catch (error) {
      console.error('Error fetching class pass products:', error);
      res.status(500).json({ error: 'Failed to fetch class pass products' });
    }
  }

  /**
   * Start a pass purchase. Everything that can refuse the sale is decided here,
   * before a Stripe session exists — a 409 that arrives after the customer has
   * paid is a refund conversation on a product with no refunds (D5, D7).
   */
  public async createPassCheckoutSession(
    req: Request,
    res: Response
  ): Promise<void> {
    try {
      const { productId, firstName, lastName } = req.body;
      // Recurring is opt-in at the API. The buying page defaults it on, but a
      // request that says nothing must never be turned into a standing charge.
      const autoRenew = req.body.autoRenew === true;
      const email: string | undefined = req.body.email?.trim().toLowerCase();

      if (!productId || !email || !firstName) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      // Only what is currently on sale can be bought: a superseded product is
      // the price somebody else paid, not an offer (D11).
      const product = await ClassPassProduct.findOne({ _id: productId, active: true });
      if (!product) {
        res.status(404).json({ error: 'Class pass not found' });
        return;
      }

      if (autoRenew && !product.allowSubscription) {
        res.status(400).json({ error: 'This pass cannot be set to renew automatically.' });
        return;
      }

      const held = await findActivePassForEmail(email);
      if (held) {
        res.status(409).json({
          error:
            `You already have an active pass, valid until ${held.validUntilDate}. ` +
            `You can buy another once it ends.`,
          validUntilDate: held.validUntilDate,
        });
        return;
      }

      const metadata = {
        kind: 'class_pass',
        productId: String(product._id),
        firstName,
        lastName: lastName || '',
        email,
      };

      const session = await stripe.checkout.sessions.create({
        expires_at: Math.floor(Date.now() / 1000) + STRIPE_SESSION_TTL_S,
        payment_method_types: ['card'],
        payment_method_options: { card: { request_three_d_secure: 'any' } },
        mode: autoRenew ? 'subscription' : 'payment',
        line_items: [
          {
            price_data: {
              currency: product.currency,
              product_data: {
                name: product.name,
                description: autoRenew
                  ? `Unlimited group classes, renewing every ${termLabel(product.months)}. ` +
                    `Cancel any time; the term you have paid for is not refunded.`
                  : `Unlimited group classes for ${product.months} months. Non-refundable.`,
              },
              unit_amount: product.priceCents,
              // The billing period is the product's own term: a 1-month product
              // bills monthly, a 3-month one quarterly (D17).
              ...(autoRenew
                ? { recurring: { interval: 'month' as const, interval_count: product.months } }
                : {}),
            },
            quantity: 1,
          },
        ],
        customer_email: email,
        metadata,
        // Renewal invoices carry the subscription, never the checkout session,
        // so the metadata has to live on the subscription too (D18).
        ...(autoRenew ? { subscription_data: { metadata } } : {}),
        // Passes get their own confirmation page: the class-booking one tells
        // people their booking is confirmed, which is not what happened here.
        success_url: `${siteBaseUrl()}/group-classes/passes/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${siteBaseUrl()}/group-classes/passes`,
      });

      res.status(200).json({ url: session.url, sessionId: session.id });
    } catch (error) {
      console.error('Error creating pass checkout session:', error);
      res.status(500).json({ error: 'Failed to start pass purchase' });
    }
  }

  /**
   * Activate a pass from a paid Stripe session and email the holder their link.
   * Safe to call repeatedly for the same session — Stripe redelivers (D14).
   */
  public async activatePassAfterPayment(metadata: {
    productId: string;
    email: string;
    firstName: string;
    lastName?: string;
    stripeSessionId: string;
    stripeSubscriptionId?: string;
  }): Promise<void> {
    const before = await ClassPass.countDocuments({
      stripeSessionId: metadata.stripeSessionId,
    });

    const pass = await activatePass({
      productId: metadata.productId,
      email: metadata.email,
      firstName: metadata.firstName,
      lastName: metadata.lastName,
      purchaseDate: venueToday(),
      stripeSessionId: metadata.stripeSessionId,
      stripeSubscriptionId: metadata.stripeSubscriptionId,
    });

    // Only mail on the delivery that actually created the pass, so a
    // redelivery does not send the customer a second copy of their link.
    if (before === 0) {
      await sendPassLinkEmail(pass);
    }
  }

  /**
   * A paid renewal invoice, applied to the pass it belongs to (D18).
   *
   * Only the extension that actually moved the date sends mail, so a
   * redelivered invoice does not tell the customer twice that they were
   * charged once.
   */
  public async renewPassFromInvoice(input: {
    stripeSubscriptionId: string;
    invoiceId: string;
  }): Promise<void> {
    const result = await applyRenewalInvoice(input);
    if (!result || !result.extended) return;

    await sendPassRenewalEmail(result.pass);
  }

  /**
   * What the classes page needs on load: who is signed in, and whether they
   * hold a usable pass.
   *
   * Being anonymous is normal, not an error — most visitors pay per class.
   */
  public async getMyPass(req: Request, res: Response): Promise<void> {
    try {
      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(200).json({ signedIn: false, pass: null });
        return;
      }

      const pass = await ClassPass.findOne({ email: customer.email }).sort({
        purchasedAt: -1,
      });

      if (!pass) {
        res.status(200).json({
          signedIn: true,
          firstName: customer.firstName,
          email: customer.email,
          pass: null,
        });
        return;
      }

      const product = await ClassPassProduct.findById(pass.productId).lean();
      const expired = !pass.revoked && pass.validUntilDate < venueToday();

      res.status(200).json({
        signedIn: true,
        firstName: customer.firstName,
        email: customer.email,
        pass: {
          valid: !pass.revoked && !expired,
          expired,
          revoked: pass.revoked,
          validFromDate: pass.validFromDate,
          validUntilDate: pass.validUntilDate,
          productName: product?.name ?? `${pass.months} Month Pass`,
          // Renewal state, so the page can show the switch (D19). A one-off
          // pass reports `recurring: false` and shows no controls at all.
          recurring: Boolean(pass.stripeSubscriptionId),
          autoRenew: pass.autoRenew,
          subscriptionStatus: pass.subscriptionStatus,
          nextChargeDate: pass.nextChargeDate,
          months: pass.months,
        },
      });
    } catch (error) {
      console.error('Error reading pass for session:', error);
      res.status(500).json({ error: 'Failed to load your pass' });
    }
  }

  /**
   * Every class the signed-in member has booked, split into what is still
   * coming and what has already run.
   *
   * Whose bookings these are comes from the session cookie; nothing in the
   * request can point it at somebody else (D2). Only the caller's own spot is
   * returned — a class document holds everybody's, and the rest is not theirs
   * to see.
   */
  public async getMyBookings(
    req: Request,
    res: Response,
    // Injected by tests. Production reads the venue clock, never the caller's.
    clock?: { today: string; nowMinutes: number }
  ): Promise<void> {
    try {
      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(401).json({ error: 'Please sign in to see your bookings.' });
        return;
      }

      const today = clock?.today ?? venueToday();
      const nowMinutes = clock?.nowMinutes ?? venueClockMinutes();
      const now = new Date();
      const email = customer.email.trim().toLowerCase();

      const classes = await GroupClass.find({
        'timeSlots.spots.email': { $regex: `^${email.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
      }).lean();

      const upcoming: Record<string, unknown>[] = [];
      const past: Record<string, unknown>[] = [];

      for (const groupClass of classes) {
        for (const slot of groupClass.timeSlots) {
          const startsAt = slotMinutes(slot.time);

          for (const spot of slot.spots) {
            if (spot.email?.trim().toLowerCase() !== email) continue;
            // A hold that was never paid for is not a booking.
            if (!isSpotActive(spot, now)) continue;
            if (spot.status === 'pending') continue;
            if (!spot.occurrenceDate) continue;

            const booking = {
              classId: String(groupClass._id),
              title: groupClass.title,
              timeSlot: slot.time,
              occurrenceDate: spot.occurrenceDate,
              durationMinutes: groupClass.durationMinutes,
              bookedWithPass: Boolean(spot.bookedWithPass),
            };

            // A class today is still ahead of you until it starts. An
            // unparseable slot time counts as not yet run, so a booking is
            // never hidden from the person who made it.
            const hasRun =
              spot.occurrenceDate < today ||
              (spot.occurrenceDate === today &&
                startsAt !== null &&
                startsAt <= nowMinutes);

            (hasRun ? past : upcoming).push(booking);
          }
        }
      }

      const byDate = (a: any, b: any) =>
        a.occurrenceDate === b.occurrenceDate
          ? String(a.timeSlot).localeCompare(String(b.timeSlot))
          : a.occurrenceDate < b.occurrenceDate
            ? -1
            : 1;

      upcoming.sort(byDate);
      past.sort((a, b) => byDate(b, a)); // most recent first

      res.status(200).json({ upcoming, past });
    } catch (error) {
      console.error('Error listing bookings:', error);
      res.status(500).json({ error: 'Failed to load your bookings' });
    }
  }

  /**
   * Turn automatic renewal on or off (D19).
   *
   * This flips Stripe's `cancel_at_period_end`; it never voids the term the
   * member has already paid for. Whose subscription it is comes from the
   * session cookie — nothing in the body can point this at somebody else (D2).
   */
  public async setAutoRenew(req: Request, res: Response): Promise<void> {
    try {
      const { autoRenew } = req.body ?? {};
      if (typeof autoRenew !== 'boolean') {
        res.status(400).json({ error: 'autoRenew must be true or false.' });
        return;
      }

      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(401).json({ error: 'Please sign in to manage your membership.' });
        return;
      }

      const pass = await ClassPass.findOne({
        email: customer.email,
        stripeSubscriptionId: { $exists: true },
      }).sort({ purchasedAt: -1 });

      if (!pass?.stripeSubscriptionId) {
        res.status(409).json({
          error: 'You have no recurring membership to change.',
        });
        return;
      }

      // Once Stripe has actually ended the subscription there is nothing left
      // to restart: resuming would need a card, and we hold none.
      if (pass.subscriptionStatus === 'canceled') {
        res.status(409).json({
          error:
            'Your membership has already ended. To start it again, buy a new one.',
        });
        return;
      }

      await stripe.subscriptions.update(pass.stripeSubscriptionId, {
        cancel_at_period_end: !autoRenew,
      });

      pass.autoRenew = autoRenew;
      pass.subscriptionStatus = autoRenew ? 'active' : 'canceling';
      await pass.save();

      res.status(200).json({
        autoRenew: pass.autoRenew,
        // What they keep either way — the whole point of cancelling at period
        // end rather than immediately.
        validUntilDate: pass.validUntilDate,
        nextChargeDate: autoRenew ? pass.nextChargeDate : undefined,
      });
    } catch (error) {
      console.error('Error changing auto-renew:', error);
      res.status(500).json({ error: 'Failed to change your renewal setting.' });
    }
  }

  /**
   * Mirror Stripe's view of a subscription onto the pass (D19).
   *
   * Stripe is the source of truth: a cancellation made in the dashboard has to
   * show up on the member's page, not be silently contradicted by our copy.
   * A subscription we do not hold is ignored rather than treated as an error —
   * the webhook must still acknowledge, or Stripe retries forever.
   */
  public async syncSubscriptionState(input: {
    stripeSubscriptionId: string;
    status: string;
    cancelAtPeriodEnd: boolean;
    currentPeriodEndDate?: string;
  }): Promise<void> {
    const pass = await ClassPass.findOne({
      stripeSubscriptionId: input.stripeSubscriptionId,
    });
    if (!pass) return;

    const ended = input.status === 'canceled' || input.status === 'incomplete_expired';

    pass.subscriptionStatus = ended
      ? 'canceled'
      : input.cancelAtPeriodEnd
        ? 'canceling'
        : 'active';
    pass.autoRenew = !ended && !input.cancelAtPeriodEnd;
    // A charge that will never come should not be advertised as due.
    pass.nextChargeDate =
      ended || input.cancelAtPeriodEnd ? undefined : input.currentPeriodEndDate;

    // Deliberately does not touch `revoked` or the term: the member keeps what
    // they paid for, and revoking is an admin act (D9).
    await pass.save();
  }

  /**
   * Book a class on a pass. No payment, so the spot is reserved and confirmed
   * in one request rather than held pending a checkout.
   *
   * The request says only which class. Who is booking comes from the session,
   * so nothing the page sends can change whose name is on the door list (D2).
   */
  public async bookWithPass(req: Request, res: Response): Promise<void> {
    try {
      const { classId, timeSlot, occurrenceDate } = req.body;

      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(401).json({ error: 'Please sign in to book with your pass.' });
        return;
      }

      if (!classId || !timeSlot) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      // No fallback from `date`: deriving the day from an ISO timestamp is
      // wrong by one in Irish summer time, and on this path a one-day error
      // lands exactly on the expiry boundary being sold (D15).
      if (!isPassDateString(occurrenceDate)) {
        res.status(400).json({ error: 'A valid occurrenceDate ("YYYY-MM-DD") is required' });
        return;
      }

      const pass = await ClassPass.findOne({ email: customer.email }).sort({
        purchasedAt: -1,
      });

      if (!pass || pass.revoked || pass.validUntilDate < venueToday()) {
        res.status(403).json({
          error:
            'You don\'t have an active pass. Buy a pass, or book this class on its own for €10.',
          needsPass: true,
        });
        return;
      }

      if (!passCovers(pass, occurrenceDate)) {
        const message =
          occurrenceDate < pass.validFromDate
            ? `Your pass starts on ${pass.validFromDate}, so it doesn't cover this class.`
            : `Your pass ends on ${pass.validUntilDate}, so it doesn't cover a class on ${occurrenceDate}.`;
        res.status(403).json({ error: message, validUntilDate: pass.validUntilDate });
        return;
      }

      // Same pool, same guard as a paying customer: first come, first served,
      // no reserved allocation for pass holders.
      const reservation = await reserveSpot(GroupClass, {
        classId,
        timeSlot,
        occurrenceDate,
        email: customer.email,
        firstName: customer.firstName ?? pass.firstName,
        lastName: customer.lastName ?? pass.lastName,
        holdTtlMs: HOLD_TTL_MS,
        now: new Date(),
        bookedWithPass: true,
      });

      if (!reservation.ok) {
        const messages: Record<string, string> = {
          notfound: 'Time slot not found',
          full: 'This time slot is fully booked',
          dup: 'You have already booked this class',
          conflict: 'Booking is busy right now, please try again',
        };
        const status = reservation.reason === 'notfound' ? 404 : 400;
        res.status(status).json({ error: messages[reservation.reason] ?? 'Unable to book' });
        return;
      }

      // There is no payment to wait for, so the hold is promoted immediately.
      const confirmed = await confirmHold(GroupClass, classId, reservation.holdId);
      if (!confirmed) {
        await releaseHold(GroupClass, classId, reservation.holdId);
        res.status(500).json({ error: 'Failed to confirm booking' });
        return;
      }

      res.status(200).json({
        booked: true,
        occurrenceDate,
        validUntilDate: pass.validUntilDate,
      });
    } catch (error) {
      console.error('Error booking with pass:', error);
      res.status(500).json({ error: 'Failed to book class' });
    }
  }

  /**
   * Release a spot the customer can no longer use, returning it to the pool
   * for resale at the normal price (D6).
   *
   * Deliberately allowed whatever state their pass is in: cancelling only ever
   * frees capacity, so refusing it would leave an empty mat in a full class
   * and help nobody.
   */
  public async cancelPassBooking(req: Request, res: Response): Promise<void> {
    try {
      const { classId, timeSlot, occurrenceDate } = req.body;

      const customer = await customerFromRequest(req);
      if (!customer) {
        res.status(401).json({ error: 'Please sign in to manage your bookings.' });
        return;
      }

      if (!classId || !timeSlot) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }
      if (!isPassDateString(occurrenceDate)) {
        res.status(400).json({ error: 'A valid occurrenceDate ("YYYY-MM-DD") is required' });
        return;
      }

      // The filter must require the spot to exist: `$inc` alone always counts
      // as a modification, so matching on the class only would report success
      // for a cancel that removed nothing.
      const result = await GroupClass.updateOne(
        {
          _id: classId,
          timeSlots: {
            $elemMatch: {
              time: timeSlot,
              spots: { $elemMatch: { email: customer.email, occurrenceDate } },
            },
          },
        },
        {
          $pull: { 'timeSlots.$[t].spots': { email: customer.email, occurrenceDate } },
          // Bump the version so any in-flight reservation loses its CAS and
          // retries against the freed pool rather than a stale count.
          $inc: { __v: 1 },
        },
        { arrayFilters: [{ 't.time': timeSlot }] }
      );

      if (result.modifiedCount !== 1) {
        res.status(404).json({ error: 'No booking found to cancel' });
        return;
      }

      res.status(200).json({ cancelled: true, occurrenceDate });
    } catch (error) {
      console.error('Error cancelling pass booking:', error);
      res.status(500).json({ error: 'Failed to cancel booking' });
    }
  }

  private async sendBookingConfirmationEmail(
    email: string,
    firstName: string,
    lastName: string,
    className: string,
    classDate: string,
    classTime: string,
    duration: number
  ): Promise<void> {
    const template_path = path.join(
      __dirname,
      '../../../',
      'templates',
      'group_class_booking.html'
    );

    const templateSource = fs.readFileSync(template_path, 'utf8');

    // Format the date nicely
    const formattedDate = new Date(classDate).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    // Replace template variables
    let html = templateSource.replace('{{className}}', className);
    html = html.replace('{{classDate}}', formattedDate);
    html = html.replace('{{classTime}}', classTime);
    html = html.replace('{{duration}}', duration.toString());
    html = html.replace('{{firstName}}', firstName);
    html = html.replace('{{lastName}}', lastName);

    const { data, error } = await resend.emails.send({
      from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
      to: [email],
      subject: `Booking Confirmed: ${className}`,
      html: html,
    });

    if (error) {
      console.error('Error sending email:', error);
      throw error;
    }

    console.log('Email sent successfully:', data);
  }

  // Create Stripe checkout session for group class booking
  public async createCheckoutSession(
    req: Request,
    res: Response
  ): Promise<void> {
    try {
      const { classId, timeSlot, firstName, lastName, email, date } = req.body;
      // occurrenceDate ("YYYY-MM-DD") identifies which week's pool this booking
      // belongs to. Fall back to the date's day for older clients.
      const occurrenceDate: string =
        req.body.occurrenceDate || new Date(date).toISOString().split('T')[0];

      if (!classId || !timeSlot || !firstName || !email || !date) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const groupClass = await GroupClass.findById(classId);
      if (!groupClass) {
        res.status(404).json({ error: 'Group class not found' });
        return;
      }

      // Reserve the spot atomically BEFORE taking payment. This is what prevents
      // overbooking: two concurrent buyers can no longer both pass a capacity
      // check and both pay — the pool is decremented here, under a CAS guard.
      const reservation = await reserveSpot(GroupClass, {
        classId,
        timeSlot,
        occurrenceDate,
        email,
        firstName,
        lastName,
        holdTtlMs: HOLD_TTL_MS,
        now: new Date(),
      });

      if (!reservation.ok) {
        const messages: Record<string, string> = {
          notfound: 'Time slot not found',
          full: 'This time slot is fully booked',
          dup: 'You have already booked this class',
          conflict: 'Booking is busy right now, please try again',
        };
        const status = reservation.reason === 'notfound' ? 404 : 400;
        res
          .status(status)
          .json({ error: messages[reservation.reason] ?? 'Unable to book' });
        return;
      }

      const { holdId } = reservation;

      // Format the date for display
      const formattedDate = new Date(date).toLocaleDateString('en-US', {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
      });

      let session;
      try {
        // Create Stripe checkout session
        session = await stripe.checkout.sessions.create({
          expires_at: Math.floor(Date.now() / 1000) + STRIPE_SESSION_TTL_S,
        payment_method_types: ['card'],
        payment_method_options: {
          card: {
            request_three_d_secure: 'any',
          },
        },
        mode: 'payment',
        line_items: [
          {
            price_data: {
              currency: 'eur',
              product_data: {
                name: `${groupClass.title} - Group Class`,
                description: `${formattedDate} at ${timeSlot} (${groupClass.durationMinutes} min)`,
              },
              unit_amount: GROUP_CLASS_PRICE_CENTS,
            },
            quantity: 1,
          },
        ],
        customer_email: email,
        metadata: {
          classId,
          timeSlot,
          firstName,
          lastName,
          email,
          date,
          occurrenceDate,
          holdId,
          className: groupClass.title,
          durationMinutes: groupClass.durationMinutes.toString(),
        },
        success_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/group-classes/success?session_id={CHECKOUT_SESSION_ID}`
            : `https://midlandsperformanceclub.ie/group-classes/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/group-classes`
            : `https://midlandsperformanceclub.ie/group-classes`,
        });
      } catch (stripeError) {
        // Stripe failed — release the hold so the spot isn't stuck pending.
        await releaseHold(GroupClass, classId, holdId);
        throw stripeError;
      }

      console.log('Checkout session created:', session.id);
      res.status(200).json({ url: session.url, sessionId: session.id });
    } catch (error) {
      console.error('Error creating checkout session:', error);
      const message =
        error instanceof Error ? error.message : 'Failed to create checkout session';
      res.status(500).json({ error: message });
    }
  }

  // Handle successful payment - called by webhook
  public async confirmBookingAfterPayment(
    classId: string,
    timeSlot: string,
    firstName: string,
    lastName: string,
    email: string,
    date: string,
    className: string,
    durationMinutes: number,
    occurrenceDate?: string,
    holdId?: string
  ): Promise<void> {
    const occurrence =
      occurrenceDate || new Date(date).toISOString().split('T')[0];

    // Normal path: the spot was already reserved as a pending hold at checkout.
    // Promote it to confirmed. Idempotent under Stripe webhook redelivery.
    if (holdId) {
      const promoted = await confirmHold(GroupClass, classId, holdId);
      if (promoted) {
        console.log('✅ Booking confirmed after payment:', email);
        await this.sendBookingConfirmationEmail(
          email,
          firstName,
          lastName,
          className,
          date,
          timeSlot,
          durationMinutes
        );
        return;
      }
      // Hold not found (already confirmed, released, or legacy) — fall through.
    }

    const groupClass = await GroupClass.findById(classId);
    if (!groupClass) {
      throw new Error('Group class not found');
    }

    const timeSlotObj = groupClass.timeSlots.find(
      (slot) => slot.time === timeSlot
    );
    if (!timeSlotObj) {
      throw new Error('Time slot not found');
    }

    // Bookings for this week's occurrence only — each week is its own pool
    const spotsThisWeek = timeSlotObj.spots.filter(
      (booking) => booking.occurrenceDate === occurrence
    );

    // Double-check booking doesn't already exist for this occurrence
    const bookingExists = spotsThisWeek.some(
      (booking) => booking.email === email
    );
    if (bookingExists) {
      console.log('Booking already exists for:', email);
      return;
    }

    // Guard against overbooking this week's pool
    if (spotsThisWeek.length >= groupClass.spotsAvailable) {
      console.error(
        `Pool full for ${className} ${occurrence} ${timeSlot}; cannot confirm ${email}`
      );
      throw new Error('This time slot is fully booked');
    }

    // Add the booking (legacy fallback — no prior hold)
    timeSlotObj.spots.push({
      email,
      firstName,
      lastName,
      bookedAt: new Date(date),
      occurrenceDate: occurrence,
      status: 'confirmed',
    });
    await groupClass.save();

    console.log('✅ Booking confirmed after payment:', email);

    // Send confirmation email
    await this.sendBookingConfirmationEmail(
      email,
      firstName,
      lastName,
      className,
      date,
      timeSlot,
      durationMinutes
    );
  }
}
