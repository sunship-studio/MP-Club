import mongoose, { Document, Schema } from 'mongoose';

/**
 * A person the club deals with, keyed by email.
 *
 * The unit identity hangs off (D16). A pass belongs to a customer rather than
 * a customer being implied by a pass, so losing a pass email costs nothing and
 * a renewal does not orphan anything.
 */
export interface ICustomer extends Document {
  email: string;
  firstName?: string;
  lastName?: string;
  createdAt: Date;
}

const CustomerSchema = new Schema<ICustomer>({
  // Always stored lowercased: the booking form takes email as free text and
  // people capitalise inconsistently.
  email: { type: String, required: true, unique: true, index: true },
  firstName: { type: String, required: false },
  lastName: { type: String, required: false },
  createdAt: { type: Date, required: true, default: Date.now },
});

const Customer = mongoose.model<ICustomer>('Customer', CustomerSchema);

export default Customer;
