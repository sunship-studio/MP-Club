import mongoose, { Document, Schema } from 'mongoose';

/**
 * A sellable pass: the €300 / 3-month product, say. Seeded by script rather
 * than edited in the admin app — pricing changes twice a year at most, and a
 * product editor is the expensive half of the admin work for the least return
 * (see docs/specs/class-pass.md D11).
 */
export interface IClassPassProduct extends Document {
  name: string;
  months: number;
  priceCents: number; // EUR, in cents, as Stripe wants it
  currency: string;
  active: boolean;
  // Whether this product may be sold as a recurring subscription (D17).
  // Recurring is a property of the sale, not a second product row: two rows at
  // the same price differing only in billing mode is two things to reprice,
  // and one of them eventually gets forgotten.
  allowSubscription: boolean;
}

const ClassPassProductSchema = new Schema<IClassPassProduct>({
  name: { type: String, required: true },
  months: { type: Number, required: true, min: 1 },
  priceCents: { type: Number, required: true, min: 0 },
  currency: { type: String, required: true, default: 'eur' },
  active: { type: Boolean, required: true, default: true },
  allowSubscription: { type: Boolean, required: true, default: false },
});

const ClassPassProduct = mongoose.model<IClassPassProduct>(
  'ClassPassProduct',
  ClassPassProductSchema
);

export default ClassPassProduct;
