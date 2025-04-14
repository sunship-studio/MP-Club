import express from "express";
import { Request, Response } from "express";
import MobileAppController from "../controllers/mobile_app";
import mobileAppAuth from "../middleware/auth";

// Mobile App Router
const mobileAppRouter = express.Router();
const mobileAppController = new MobileAppController();

// Route to get the waiting list
mobileAppRouter.get(
  "/waiting-list",
  mobileAppAuth,
  async (req: Request, res: Response) => {
    await mobileAppController.getWaitingList(req, res);
  }
);

// Route to get online subscriptions
mobileAppRouter.get(
  "/online-subscriptions",

  mobileAppAuth,
  async (req: Request, res: Response) => {
    await mobileAppController.getOnlineSubscriptions(req, res);
  }
);

mobileAppRouter.post(
  '/waiting-list/reject',
  mobileAppAuth,
  async (req: Request, res: Response) => {
    await mobileAppController.rejectWaitingList(req, res);
  }
)

mobileAppRouter.post(
  '/waiting-list/accept',
  mobileAppAuth,
  async (req: Request, res: Response) => {
    await mobileAppController.acceptWaitingList(req, res);
  }
)

export default mobileAppRouter;