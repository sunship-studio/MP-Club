import mongoose, { Schema, Document } from "mongoose";

interface IPaymentSession extends Document {
  sessionId: string;
  email: string;
  age: number;
  firstName: string;
  lastName: string;
}

const PaymentSessionSchema = new Schema<IPaymentSession>({
  sessionId: { type: String, required: true },
  email: { type: String, required: true },
  age: { type: Number, required: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
});

const PaymentSession = mongoose.model<IPaymentSession>(
  "PaymentSession",
  PaymentSessionSchema
);


export default PaymentSession;