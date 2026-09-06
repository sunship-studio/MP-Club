import mongoose, { Document, Schema } from 'mongoose';

/**
 * One purchased pass, belonging to the customer with this email.
 *
 * There is no credential here: entitlement is proved by being signed in as
 * that customer (D16). The pass used to carry a bearer token, which died with
 * the pass and so made a lost email unrecoverable — that is what D16 fixed.
 *
 * Term dates are `"YYYY-MM-DD"` strings, never `Date`, and are compared
 * lexicographically — see services/class_pass.ts for why (D4).
 */
export interface IClassPass extends Document {
  email: string;
  firstName: string;
  lastName?: string;
  productId: mongoose.Types.ObjectId;
  months: number;
  pricePaidCents: number;
  validFromDate: string;
  validUntilDate: string;
  revoked: boolean;
  purchasedAt: Date;
  stripeSessionId?: string; // absent on a manual admin grant (D12)
  grantedByAdmin: boolean;

  // --- Recurring billing (D17–D19). All absent on a one-off pass. ---
  stripeSubscriptionId?: string;
  /** Our mirror of Stripe's `cancel_at_period_end`, inverted, for display. */
  autoRenew: boolean;
  /** Mirror of Stripe's subscription status; Stripe stays the source of truth. */
  subscriptionStatus?: 'active' | 'canceling' | 'canceled';
  /** When the next charge falls due, `"YYYY-MM-DD"`, for the member to see. */
  nextChargeDate?: string;
  /**
   * Invoices already spent on extending this pass. A redelivered `invoice.paid`
   * must not buy the customer a second month (D18) — same guarantee as D14's
   * unique `stripeSessionId`, expressed as a set because there are many.
   */
  consumedInvoiceIds: string[];
}

const ClassPassSchema = new Schema<IClassPass>({
  email: { type: String, required: true, index: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: false },
  productId: { type: Schema.Types.ObjectId, ref: 'ClassPassProduct', required: true },
  months: { type: Number, required: true },
  pricePaidCents: { type: Number, required: true },
  validFromDate: { type: String, required: true },
  validUntilDate: { type: String, required: true },
  revoked: { type: Boolean, required: true, default: false },
  purchasedAt: { type: Date, required: true, default: Date.now },
  // Unique when present, so a replayed Stripe webhook cannot mint a second
  // pass for the same checkout session (D14).
  stripeSessionId: { type: String, required: false, unique: true, sparse: true },
  grantedByAdmin: { type: Boolean, required: true, default: false },

  // Unique when present: one pass per subscription, so a renewal can find the
  // pass it belongs to without ambiguity.
  stripeSubscriptionId: { type: String, required: false, unique: true, sparse: true },
  autoRenew: { type: Boolean, required: true, default: false },
  subscriptionStatus: {
    type: String,
    required: false,
    enum: ['active', 'canceling', 'canceled'],
  },
  nextChargeDate: { type: String, required: false },
  consumedInvoiceIds: { type: [String], required: true, default: [] },
});

const ClassPass = mongoose.model<IClassPass>('ClassPass', ClassPassSchema);

export default ClassPass;
