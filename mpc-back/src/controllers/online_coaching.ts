import { Request, Response } from "express";
import stripe from "../config/stripe";
import PaymentSession from "../models/PaymentSession";
export default class OnlineCoachingController {
  constructor() {
    // Initialize any properties or dependencies here
  }

  async createCheckoutSession(req: Request, res: Response) {
    console.log("Creating checkout session...");
    console.log("Request body:", req.body);
    const { email, firstName, lastName, age } = req.body;

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
      console.log("Session created:", session);
      // Store the session ID in your database or perform any other necessary actions
      await PaymentSession.create({
        sessionId: session.id,
        email,
        firstName,
        lastName,
        age,
      })
        .then(() => {
          console.log("Payment session saved to database");
        })
        .catch((error) => {
          console.error("Error saving payment session:", error);
        });

      res.status(200).json({
        sessionId: session.id,
      });
    } catch (error) {
      console.error("Error creating subscription:", error);
      res.status(500).json({ error: "Failed to create subscription" });
    }
  }

  async handleWebhook(req: Request, res: Response) {
    const sig = req.headers["stripe-signature"];
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

    let event;

    try {
      event = stripe.webhooks.constructEvent(req.body, sig!, endpointSecret!);
    } catch (err) {
      console.error("Error verifying webhook signature:", err);
      return res.status(400).send(`Webhook Error: ${err}`);
    }

    // Handle the event
    switch (event.type) {
      case "checkout.session.completed":
        const session = event.data.object;
        console.log("Payment successful:", session);
        break;
      case "checkout.session.async_payment_failed":
        console.log("Payment failed:", event.data.object);
        break;
      default:
        console.warn(`Unhandled event type: ${event.type}`);
    }

    res.status(200).json({ received: true });
  }
}
