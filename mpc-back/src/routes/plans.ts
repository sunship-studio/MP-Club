import express from "express";

import PlansController from "../controllers/plans";
import { Request, Response } from "express";

import bodyParser from "body-parser";

// Plans Router
const plansRouter = express.Router();
const plansController = new PlansController();

// Purchase Plan
plansRouter.post("/create-checkout-session", bodyParser.json(), plansController.createCheckoutSession);



// webhook for Stripe
plansRouter.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),

  async (req: Request, res: Response) => {
    plansController.handleWebhook(req, res);
  }
);


export default plansRouter;