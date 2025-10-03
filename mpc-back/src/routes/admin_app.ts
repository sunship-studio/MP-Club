import express from "express";
import { Request, Response } from "express";

import adminAppAuth from "../middleware/auth";
import AdminAppController from "../controllers/admin_app";

// Mobile App Router
const adminAppRouter = express.Router();
const adminAppController = new AdminAppController();

// Route to get the waiting list
adminAppRouter.get(
  "/waiting-list",
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getWaitingList(req, res);
  }
);

// Route to get online subscriptions
adminAppRouter.get(
  "/online-users",

  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getOnlineCoachingUsers(req, res);
  }
);

adminAppRouter.post(
  "/waiting-list/reject",
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.rejectWaitingList(req, res);
  }
);

adminAppRouter.post(
  "/waiting-list/accept",
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.acceptWaitingList(req, res);
  }
);

adminAppRouter.post(
  "/user-calories",
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log("Received request to save user calories:", req.body);
    await adminAppController.saveUserCalories(req, res);
  }
);

export default adminAppRouter;
