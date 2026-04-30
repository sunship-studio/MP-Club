import express from "express";
import OnlineCoachingController from "../controllers/web/online_coaching";

import bodyParser from "body-parser";

// Online Coaching Router
const onlineCoachingRouter = express.Router();
const onlineCoachingController = new OnlineCoachingController();

// Create Subscription
onlineCoachingRouter.post(
  "/create-checkout-session",
  bodyParser.json(),
  onlineCoachingController.createCheckoutSession
);

onlineCoachingRouter.post(
  "/cancel",
  onlineCoachingController.cancelSubscription
);

onlineCoachingRouter.post(
  "/confirm_cancel",
  bodyParser.json(),
  onlineCoachingController.confirmCancelSubscription
);

export default onlineCoachingRouter;
