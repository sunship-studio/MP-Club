"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleGroupClassWebhook = void 0;
const stripe_1 = __importDefault(require("stripe"));
const GroupClass_1 = __importDefault(require("../models/GroupClass"));
const group_classes_1 = require("../routes/group_classes");
const group_class_booking_1 = require("../services/group_class_booking");
/**
 * A Stripe epoch as a `"YYYY-MM-DD"` date in the venue's timezone. Dates on a
 * pass are never `Date` objects — see services/class_pass.ts for why (D4).
 */
function venueDateFromEpoch(seconds) {
    return new Intl.DateTimeFormat('en-CA', {
        timeZone: 'Europe/Dublin',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
    }).format(new Date(seconds * 1000));
}
const stripe = new stripe_1.default(process.env.NODE_ENV === 'development'
    ? process.env.STRIPE_TEST_SECRET_KEY
    : process.env.STRIPE_SECRET_KEY);
/**
 * Webhook signing secrets, from the environment only.
 *
 * Accepts a comma-separated list so a secret can be rolled without dropping
 * events: Stripe's old and new secrets are both live during the overlap, and
 * a single-secret check rejects every delivery signed with the other one.
 *
 * There used to be hardcoded fallbacks here. They were removed because a
 * signing secret does not belong in the repository — but note that the literal
 * was *correct*; what broke production was the environment variable being set
 * to a different destination's secret, which the fallback had been masking.
 * Hence the list: setting one wrong value should not be silent.
 *
 * Each destination has its own URL and its own secret:
 *   /webhook             online coaching
 *   /plan_webhook        training plans
 *   /group_class_webhook group classes and passes  ← this one
 */
const endpointSecrets = ((_a = process.env.STRIPE_WEBHOOK_SECRET) !== null && _a !== void 0 ? _a : '')
    .split(',')
    .map((secret) => secret.trim())
    .filter(Boolean);
if (endpointSecrets.length === 0) {
    throw new Error('STRIPE_WEBHOOK_SECRET is not set, so the group class webhook cannot verify ' +
        'Stripe signatures and would reject every payment event. Set it to the ' +
        "signing secret of this environment's Stripe event destination " +
        '(Stripe → Developers → Webhooks → the destination → Signing secret), ' +
        'as a Railway service variable in production or in mpc-back/.env locally. ' +
        'If several destinations post to this URL, list every secret, comma-separated.');
}
/**
 * Verify against each configured secret, accepting the first that matches.
 *
 * This is not weaker than checking one: a forged payload still has to carry a
 * valid HMAC for a secret we hold. It only stops us rejecting genuine events
 * from a second destination we also own.
 */
function constructEvent(payload, signature) {
    let lastError;
    for (const secret of endpointSecrets) {
        try {
            return stripe.webhooks.constructEvent(payload, signature, secret);
        }
        catch (error) {
            lastError = error;
        }
    }
    throw lastError;
}
const handleGroupClassWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        event = constructEvent(req.body, sig);
    }
    catch (err) {
        console.error('⚠️ Webhook signature verification failed:', err.message);
        res.status(400).send(`Webhook Error: ${err.message}`);
        return;
    }
    // Handle the checkout.session.completed event
    if (event.type === 'checkout.session.completed') {
        const session = event.data.object;
        console.log('✅ Group class payment completed:', session.id);
        // Extract metadata
        const metadata = session.metadata;
        if (!metadata) {
            console.error('No metadata found in session');
            res.status(400).send('No metadata found');
            return;
        }
        // Pass purchases share this endpoint with class bookings — one Stripe
        // webhook config, one signature verification path (D14). They are told
        // apart by metadata.kind, which only pass checkouts set.
        if (metadata.kind === 'class_pass') {
            try {
                yield group_classes_1.groupClassController.activatePassAfterPayment({
                    productId: metadata.productId,
                    email: metadata.email,
                    firstName: metadata.firstName,
                    lastName: metadata.lastName || '',
                    stripeSessionId: session.id,
                    // Present only on a subscription checkout (D17). Expanded or not,
                    // Stripe gives either the id or the object here.
                    stripeSubscriptionId: typeof session.subscription === 'string'
                        ? session.subscription
                        : (_a = session.subscription) === null || _a === void 0 ? void 0 : _a.id,
                });
                console.log('✅ Class pass activated for:', metadata.email);
            }
            catch (error) {
                console.error('Error activating class pass:', error);
                // Don't return an error — Stripe will retry, and activation is
                // idempotent on the session id.
            }
            res.status(200).json({ received: true });
            return;
        }
        const { classId, timeSlot, firstName, lastName, email, date, occurrenceDate, holdId, className, durationMinutes, } = metadata;
        try {
            // Confirm the booking
            yield group_classes_1.groupClassController.confirmBookingAfterPayment(classId, timeSlot, firstName, lastName || '', email, date, className, parseInt(durationMinutes, 10), occurrenceDate, holdId);
            console.log('✅ Booking confirmed for:', email);
        }
        catch (error) {
            console.error('Error confirming booking:', error);
            // Don't return error - Stripe will retry
        }
    }
    // A membership renewal was paid for. The pass it belongs to gets its end
    // date pushed out; no new pass is created (D18).
    if (event.type === 'invoice.paid') {
        const invoice = event.data.object;
        const subscriptionId = typeof invoice.subscription === 'string'
            ? invoice.subscription
            : (_b = invoice.subscription) === null || _b === void 0 ? void 0 : _b.id;
        // The first invoice of a subscription is the purchase itself, which
        // `checkout.session.completed` already turned into a pass. Extending on it
        // would hand the buyer a free extra term.
        const isFirstCharge = invoice.billing_reason === 'subscription_create';
        if (subscriptionId && !isFirstCharge) {
            try {
                yield group_classes_1.groupClassController.renewPassFromInvoice({
                    stripeSubscriptionId: subscriptionId,
                    invoiceId: invoice.id,
                });
                console.log('🔁 Membership renewed for subscription:', subscriptionId);
            }
            catch (error) {
                console.error('Error renewing pass from invoice:', error);
                // Swallowed on purpose: extension is idempotent on the invoice id, so
                // Stripe's retry is safe, and a 500 here would stall the whole webhook.
            }
        }
    }
    // Stripe is the source of truth for a subscription's state: a cancellation
    // made in the dashboard has to reach the member's page (D19).
    if (event.type === 'customer.subscription.updated' ||
        event.type === 'customer.subscription.deleted') {
        const subscription = event.data.object;
        const periodEnd = subscription.current_period_end;
        try {
            yield group_classes_1.groupClassController.syncSubscriptionState({
                stripeSubscriptionId: subscription.id,
                status: event.type === 'customer.subscription.deleted' ? 'canceled' : subscription.status,
                cancelAtPeriodEnd: Boolean(subscription.cancel_at_period_end),
                currentPeriodEndDate: periodEnd ? venueDateFromEpoch(periodEnd) : undefined,
            });
        }
        catch (error) {
            console.error('Error syncing subscription state:', error);
        }
    }
    // Checkout abandoned/expired — release the pending hold so the spot frees up.
    if (event.type === 'checkout.session.expired') {
        const session = event.data.object;
        const metadata = session.metadata;
        if ((metadata === null || metadata === void 0 ? void 0 : metadata.classId) && (metadata === null || metadata === void 0 ? void 0 : metadata.holdId)) {
            try {
                yield (0, group_class_booking_1.releaseHold)(GroupClass_1.default, metadata.classId, metadata.holdId);
                console.log('🕓 Released expired hold:', metadata.holdId);
            }
            catch (error) {
                console.error('Error releasing expired hold:', error);
            }
        }
    }
    res.status(200).json({ received: true });
});
exports.handleGroupClassWebhook = handleGroupClassWebhook;
