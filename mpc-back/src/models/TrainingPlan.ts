import mongoose, { Schema } from 'mongoose';

export interface ITrainingPlan {
  name: string;
  excelFileUrl: string;
  price: number;
  listOfExercises: string[];
  stripeProductId: string;
}

export const TrainingPlanSchema = new Schema<ITrainingPlan>(
  {
    name: { type: String, required: true },
    price: { type: Number, required: true },
    excelFileUrl: { type: String, required: true },
    listOfExercises: { type: [String], required: true },

    stripeProductId: { type: String, required: true },
  },
  { timestamps: true }
);

export const TrainingPlan = mongoose.model<ITrainingPlan>(
  'TrainingPlan',
  TrainingPlanSchema
);
