import { Request, Response } from "express";
import stripe from "../config/stripe";
export default class OnlineCoachingController {
  constructor() {
    // Initialize any properties or dependencies here
  }

  async createCheckoutSession(req: Request, res: Response) {
    console.log(process.env.NODE_ENV);
    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "subscription",
        line_items: [
          {
            price: process.env.STRIPE_PRICE_ID,
            quantity: 1,
          },
        ],
        success_url:
          process.env.NODE_ENV === "development"
            ? `http://localhost:3000/online-coaching/success`
            : `${req.protocol}://${req.get("host")}/online-coaching/success`,
        cancel_url:
          process.env.NODE_ENV === "development"
            ? `http://localhost:3000/online-coaching/`
            : `${req.protocol}://${req.get("host")}/online-coaching/`,
      });

      res.status(200).json({
        sessionId: session.id,
      });
    } catch (error) {
      console.error("Error creating subscription:", error);
      res.status(500).json({ error: "Failed to create subscription" });
    }
  }
}
