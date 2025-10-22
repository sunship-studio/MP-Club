import mongoose, { Schema } from "mongoose";

export  interface IPasswordResetToken extends Document {
userId: mongoose.Types.ObjectId;
    token: string;
    expiry: number;
    used: boolean;
}


const PasswordResetTokenSchema = new Schema<IPasswordResetToken>({
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    token: { type: String, required: true },
    expiry: { type: Number, required: true },
    used: { type: Boolean, default: false },
});

const PasswordResetToken = mongoose.model<IPasswordResetToken>('PasswordResetToken', PasswordResetTokenSchema);

export default PasswordResetToken;
