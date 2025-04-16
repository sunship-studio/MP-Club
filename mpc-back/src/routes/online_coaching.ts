import express from "express";
import OnlineCoachingController from "../controllers/online_coaching";
import { Request, Response } from "express";

import bodyParser from "body-parser";
import { on } from "events";

// Online Coaching Router
const onlineCoachingRouter = express.Router();
const onlineCoachingController = new OnlineCoachingController();

// Create Subscription
onlineCoachingRouter.post(
  "/create-checkout-session",
  bodyParser.json(),
  onlineCoachingController.createCheckoutSession
);

// webhook for Stripe
onlineCoachingRouter.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),
  async (req: Request, res: Response) => {
    onlineCoachingController.handleWebhook(req, res);
  }
);

onlineCoachingRouter.post(
  '/cancel',
  onlineCoachingController.cancelSubscription
)

export default onlineCoachingRouter;
