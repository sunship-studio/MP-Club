import stripe from "../config/stripe";
import { Request, Response } from "express";
export default class PlansController {
  constructor() {}

  async createCheckoutSession(req: Request, res: Response) {
    console.log("Creating checkout session...");
    console.log("Request body:", req.body);
    const { priceId } = req.body;
    console.log("Price ID:", priceId);

    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        success_url:
          process.env.NODE_ENV === "development"
            ? `http://localhost:3000/plans/success`
            : `${req.protocol}://${req.get("host")}/plans/success`,
        cancel_url:
          process.env.NODE_ENV === "development"
            ? `http://localhost:3000/plans/`
            : `${req.protocol}://${req.get("host")}/plans/`,
      });
      console.log("Session created:", session);
      // Store the session ID in your database or perform any other necessary actions

      res.status(200).json({
        sessionId: session.id,
      });
    } catch (error) {
      console.error("Error creating subscription:", error);
      res.status(500).json({ error: "Failed to create subscription" });
    }
  }

  async handleWebhook(req: any, res: any) {
    // Logic to handle webhook events from Stripe
    res.status(200).send("Webhook received");
  }
}
