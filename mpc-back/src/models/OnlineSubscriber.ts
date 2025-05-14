import mongoose, { Schema } from "mongoose";

export interface IOnlineSubscriber extends Document {
  customerId: string;
  subscriptionId: string;
  status: string;
  startDate: Date;
  firstName: string;
  lastName: string;
  email: string;
  age: number;
  cancelToken?: string;
}

const OnlineSubscriberSchema = new Schema<IOnlineSubscriber>({
  customerId: { type: String, required: true },
  subscriptionId: { type: String, required: true },
  status: { type: String, required: true },
  startDate: { type: Date, default: Date.now },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  age: { type: Number, required: true },

  cancelToken: { type: String },
  // Optional field for storing the cancel token
});

const OnlineSubscriber = mongoose.model<IOnlineSubscriber>(
  "OnlineSubscriber",
  OnlineSubscriberSchema
);
export default OnlineSubscriber;
