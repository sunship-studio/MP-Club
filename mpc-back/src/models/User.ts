import mongoose, { Schema } from "mongoose";

export interface IUser extends Document {
  customerId: string;
  token?: string;
  refreshToken?: string;
  subscriptionId: string;
  status: string;
  type: string;
  caloriesPerDay?: number;
  hasPassword?: boolean;
  lastLogin?: Date;
  passwordHash?: string;
  trainingPlan: [
    { exerciseId: string; sets: number; reps: number; rir: number; name: string }[]
  ];
  startDate: Date;
  firstName: string;
  lastName: string;
  email: string;
  age: number;
  cancelToken?: string;
}

const UserSchema = new Schema<IUser>({
  customerId: { type: String, required: true },
  subscriptionId: { type: String, required: true },
  status: { type: String, required: true },
  startDate: { type: Date, default: Date.now },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  age: { type: Number, required: true },

  type: { type: String, required: true },
  caloriesPerDay: { type: Number },
  hasPassword: { type: Boolean, default: false },
  lastLogin: { type: Date },
  passwordHash: { type: String },
  trainingPlan: [
    [
      {
        exerciseId: { type: String, required: true },
        sets: { type: Number, required: true },
        reps: { type: Number, required: true },
        rir: { type: Number, required: true },
        name: { type: String, required: true }, 
      },
    ],
  ],

  cancelToken: { type: String },
  // Optional field for storing the cancel token
});

const User = mongoose.model<IUser>("User", UserSchema);
export default User;
