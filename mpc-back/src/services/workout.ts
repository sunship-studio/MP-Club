import User from "../models/User";

export class WorkoutService {
  static async getTrainingPlan(userId: string) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.trainingPlan;
  }

  static async getExercises(userId: string, dayIndex: number) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user.trainingPlan[dayIndex] || [];
  }

  
}
