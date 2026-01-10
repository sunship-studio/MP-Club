import mongoose, { Schema } from 'mongoose';
import { TrainingDay } from './User';

export interface IPlanForSale {
  excelFileUrl: string;
  lastUpdated?: Date;
  name: string;
  days: TrainingDay[];
  priceId: string;
  stripeProductId: string;
  price: number;
  bodyParts: string[];
}

export const PlanForSaleSchema = new Schema<IPlanForSale>(
  {
    excelFileUrl: { type: String, required: true },
    lastUpdated: { type: Date },
    name: { type: String, required: true },
    days: [
      {
        lastUpdated: { type: Date },
        name: { type: String, required: true },
        exercises: [
          {
            videoUrl: { type: String, required: false },
            bodyParts: { type: [String], default: [] },
            exerciseId: { type: String, required: true },
            minutes: { type: Number, default: 0 },
            seconds: { type: Number, default: 0 },
            sets: [
              {
                reps: { type: Number, required: true },
                rir: { type: Number, required: true },
                weight: { type: Number, required: true },
              },
            ],
            name: { type: String, required: true },
          },
        ],
      },
    ],
    priceId: { type: String, required: true },
    price: { type: Number, required: true },
    stripeProductId: { type: String, required: true },
    bodyParts: { type: [String], default: [] },
  },
  { timestamps: true }
);

export const PlanForSale = mongoose.model<IPlanForSale>(
  'PlanForSale',
  PlanForSaleSchema
);
