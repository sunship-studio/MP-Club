import { Request, Response } from "express";
import { WaitingListEntry } from "../models/WaitingListEntry";
import stripe from "../config/stripe";
import OnlineSubscriber from "../models/OnlineSubscriber";
export default class MobileAppController {
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

  public async getOnlineSubscriptions(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const subscriptions = await OnlineSubscriber.find();
      console.log("Subscriptions:", subscriptions);
      return res.status(200).json(subscriptions);
    } catch (error) {
      console.error("Error fetching online subscriptions:", error);
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
}
