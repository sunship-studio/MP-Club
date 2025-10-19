import { Request, Response } from "express";
import User from "../../models/User";

 class WorkoutController {

      async logWorkout(req: Request, res: Response){
    const { userId, workout } = req.body;
    try {
      const user = await User.findById(userId);
      if (!user) {
        console.error("User not found");
        return false;
      }
      console.log("Workout to be logged:", workout);

      user.doneWorkouts.push(workout);
      await user.save();
      res.status(200).json({ success: true });
    } catch (error) {
      console.error("Error logging workout:", error);
      res.status(500).json({ success: false })  ;
    }
  }

 }



module.exports = new WorkoutController();
