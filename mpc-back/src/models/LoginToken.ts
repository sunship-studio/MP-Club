import mongoose, { Document, Schema } from 'mongoose';

/**
 * A single-use sign-in link.
 *
 * Only the hash is stored: a leaked database read must not hand somebody a
 * working set of sign-in links.
 */
export interface ILoginToken extends Document {
  tokenHash: string;
  customerId: mongoose.Types.ObjectId;
  expiresAt: Date;
  usedAt?: Date;
}

const LoginTokenSchema = new Schema<ILoginToken>({
  tokenHash: { type: String, required: true, unique: true, index: true },
  customerId: { type: Schema.Types.ObjectId, ref: 'Customer', required: true },
  expiresAt: { type: Date, required: true },
  usedAt: { type: Date, required: false },
});

// Mongo sweeps spent and stale links on its own.
LoginTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 60 * 60 * 24 });

const LoginToken = mongoose.model<ILoginToken>('LoginToken', LoginTokenSchema);

export default LoginToken;
