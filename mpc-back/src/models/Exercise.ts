import mongoose, { Schema, Document } from "mongoose";

export interface IExercise extends Document {
  name: string;
  imageUrl?: string;
  videoUrl?: string;
  description?: string;
  bodyParts: string[];
}

const ExerciseSchema = new Schema<IExercise>({
  name: { type: String, required: true },
  imageUrl: { type: String },
  videoUrl: { type: String },
  description: { type: String },
  bodyParts: { type: [String], required: true },
});

const Exercise = mongoose.model<IExercise>("Exercise", ExerciseSchema);
export default Exercise;
