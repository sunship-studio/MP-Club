import { Request, Response } from "express";
import Exercise from "../../models/Exercise";
import User from "../../models/User";
import { WaitingListEntry } from "../../models/WaitingListEntry";
export default class AdminAppController {
  public async getAllExercises(req: Request, res: Response): Promise<Response> {
    try {
      const exercises = await Exercise.find();
      return res.status(200).json(exercises);
    } catch (error) {
      console.error("Error fetching exercises:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }



  public async getWaitingList(req: Request, res: Response): Promise<Response> {
    try {
      const waitingList = await WaitingListEntry.find();
      if (!waitingList || waitingList.length === 0) {
        return res.status(404).json({ message: "No entries found" });
      }
      // Sort the waiting list by createdAt in descending order
      waitingList.sort((a, b) => {
        return b.dateApplied.getTime() - a.dateApplied.getTime();
      });

      return res.status(200).json(waitingList);
    } catch (error) {
      console.error("Error fetching waiting list:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async saveTrainingPlan(
    req: Request,
    res: Response
  ): Promise<Response | void> {
    try {
      const { userId, trainingPlan } = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      console.log("Training Plan to be saved:", trainingPlan.days[0].exercises);
      user.trainingPlan = trainingPlan;
      user.trainingPlan.lastUpdated = new Date();
      await user.save();
      return res.status(200).json({ message: "Training plan saved" });
    } catch (error) {
      console.error("Error saving training plan:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async getUsers(req: Request, res: Response): Promise<Response> {
    try {
      const subscriptions = await User.find();
      console.log("Subscriptions:", subscriptions);
      return res.status(200).json(subscriptions);
    } catch (error) {
      console.error("Error fetching online subscriptions:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async getOnlineCoachingUsers(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const users = await User.find({ type: "online_coaching" });
      return res.status(200).json(users);
    } catch (error) {
      console.error("Error fetching online coaching users:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async rejectWaitingList(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id } = req.body;
      const entry = await WaitingListEntry.findById(id);
      if (!entry) {
        return res.status(404).json({ message: "Entry not found" });
      }
      entry.approvalStatus = "rejected";
      await entry.save();
      return res.status(200).json({ message: "Entry rejected" });
    } catch (error) {
      console.error("Error rejecting waiting list entry:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async acceptWaitingList(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id } = req.body;
      const entry = await WaitingListEntry.findById(id);
      if (!entry) {
        return res.status(404).json({ message: "Entry not found" });
      }
      entry.approvalStatus = "approved";
      entry.approvedDate = new Date();
      await entry.save();
      return res.status(200).json({ message: "Entry approved" });
    } catch (error) {
      console.error("Error approving waiting list entry:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }
  public async saveUserCalories(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id, calories } = req.body;
      const user = await User.findById(id);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      user.caloriesPerDay = calories;
      await user.save();
      return res.status(200).json({ message: "Calories updated" });
    } catch (error) {
      console.error("Error updating user calories:", error);
      return res.status(500).json({ message: "Internal server error" });
    }
  }

  public async saveUserTargetWeight(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id, targetWeight } = req.body;
      const user = await User.findById(id);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      user.targetWeight = targetWeight;
      await user.save();
      return res.status(200).json({ message: "Target weight updated" });
    } catch (error) {
      console.error("Error updating user target weight:", error);
      return res.status(500).json({ message: "Internal server error" });
    }

  }



}
