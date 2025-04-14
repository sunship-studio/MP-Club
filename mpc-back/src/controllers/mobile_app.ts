import { Request, Response } from "express";
import { WaitingListEntry } from "../models/WaitingListEntry";
import stripe from "../config/stripe";
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
      const subscriptions = await stripe.subscriptions.list({

        expand: ["data.customer"],
        price: process.env.STRIPE_PRICE_ID,
      });
      if (!subscriptions || subscriptions.data.length === 0) {
        return res.status(404).json({ message: "No subscriptions found" });
      }
      // Sort the subscriptions by createdAt in descending order
      subscriptions.data.sort((a, b) => {
        return b.created - a.created;
      });
      return res.status(200).json(
        subscriptions.data
          .map((sub) => {
            if (
              typeof sub.customer !== "string" &&
              sub.customer &&
              !sub.customer.deleted
            ) {
              return {
                customerId: sub.customer.id,
                email: sub.customer.email || "No email",
                subscriptionId: sub.id,
                startDate: sub.start_date,
                status: sub.status,
              };
            }
            return null;
          })
          .filter(Boolean)
      );
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
