import mongoose, { Schema } from "mongoose";

export interface IExercise extends Document {
  name: string;
  videoUrl: string;
  thumbnailUrl: string;
  sets: number;
  reps: number;
  rir: number;
  weight: number;
}
const ExerciseSchema = new Schema<IExercise>({
  name: { type: String, required: true },
  videoUrl: { type: String, required: true },
  thumbnailUrl: { type: String, required: true },
  sets: { type: Number, required: true },
  reps: { type: Number, required: true },
  rir: { type: Number, required: true },
  weight: { type: Number, required: true },
});

const Exercise = mongoose.model<IExercise>("Exercise", ExerciseSchema);
export default Exercise;
