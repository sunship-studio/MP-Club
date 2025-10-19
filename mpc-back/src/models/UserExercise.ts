import mongoose, { Schema } from "mongoose";

export interface IUserExercise extends Document {
  name: string;
  videoUrl: string;
  thumbnailUrl: string;
  sets: number;
  reps: number;
  rir: number;
  weight: number;
}
const UserExerciseSchema = new Schema<IUserExercise>({
  name: { type: String, required: true },
  videoUrl: { type: String, required: true },
  thumbnailUrl: { type: String, required: true },
  sets: { type: Number, required: true },
  reps: { type: Number, required: true },
  rir: { type: Number, required: true },
  weight: { type: Number, required: true },
});

const UserExercise = mongoose.model<IUserExercise>(
  "UserExercise",
  UserExerciseSchema
);
export default UserExercise;
