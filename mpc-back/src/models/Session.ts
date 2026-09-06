import mongoose, { Document, Schema } from 'mongoose';

/**
 * A signed-in browser.
 *
 * Kept server-side rather than encoded into the cookie so that signing out,
 * or Shane cutting somebody off, takes effect immediately instead of whenever
 * a self-describing token happens to expire.
 */
export interface ISession extends Document {
  tokenHash: string;
  customerId: mongoose.Types.ObjectId;
  createdAt: Date;
  expiresAt: Date;
  revokedAt?: Date;
}

const SessionSchema = new Schema<ISession>({
  tokenHash: { type: String, required: true, unique: true, index: true },
  customerId: { type: Schema.Types.ObjectId, ref: 'Customer', required: true },
  createdAt: { type: Date, required: true, default: Date.now },
  expiresAt: { type: Date, required: true },
  revokedAt: { type: Date, required: false },
});

SessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 60 * 60 * 24 });

const Session = mongoose.model<ISession>('Session', SessionSchema);

export default Session;
