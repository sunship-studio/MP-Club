import express from "express";
import OnlineCoachingController from "../controllers/online_coaching";
import { Request, Response } from "express";

// Online Coaching Router
const onlineCoachingRouter = express.Router();
const onlineCoachingController = new OnlineCoachingController();

// Create Subscription
onlineCoachingRouter.get(
  "/create-checkout-session",
  onlineCoachingController.createCheckoutSession
);


export default onlineCoachingRouter;