import mongoose, { mongo } from "mongoose";
import ChatRoom from "../models/ChatRoom";
import User from "../models/User";
import Message from "../models/Message";

class UserService {
  static async getUserById(userId: string) {
    return User.findById(userId);
  }
  static async getAllUsers() {
    return User.find({});
  }
  static async createUser(data: {
    email: string;
    name: string;
    passwordHash?: string;
    hasPassword?: boolean;
  }) {
    const user = new User(data);
    await user.save();
    return user;
  }
  static async updateUser(
    userId: string,
    data: { name?: string; email?: string; passwordHash?: string }
  ) {
    return User.findByIdAndUpdate(userId, data, { new: true });
  }
  static async setCalorieLimit(userId: string, calorieLimit: number) {
    return User.findByIdAndUpdate(userId, { calorieLimit }, { new: true });
  }
  static async setTrainingPlan(
    userId: string,
    trainingPlan: [
      {
        exerciseId: { type: String; required: true };
        sets: { type: Number; required: true };
        reps: { type: Number; required: true };
        rir: { type: Number; required: true };
      }
    ]
  ) {
    return User.findByIdAndUpdate(userId, { trainingPlan }, { new: true });
  }
}
