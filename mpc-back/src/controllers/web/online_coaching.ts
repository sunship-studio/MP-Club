import { Request, Response } from "express";
import fs from "fs";
import path from "path";
import transporter from "../../config/mailer";
import stripe from "../../config/stripe";
import PaymentSession from "../../models/PaymentSession";
import OnlineSubscriber from "../../models/User";
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


  public async cancelSubscription(req: Request, res: Response) {
    const { email } = req.body;
    try {
      // generate token for the customer
      const customer = await stripe.customers.list({
        email: email,
      });
      if (customer.data.length === 0) {
        res.status(404).json({ error: "Customer not found" });
      }
      // Token generation
      const token = await generateToken(customer.data[0].id);
      const subscriber = await OnlineSubscriber.findOneAndUpdate(
        { email: email },
        { cancelToken: token }
      );
      // Template emails
      const template_path = path.join(
        __dirname,
        "templates",
        "online_cancelation.html"
      );
      const templateSource = readHTMLFile(template_path);
      const template = Handlebars.compile(templateSource);
      const htmlToSend = template({
        cancelUrl: `midlandsperformanceclub.ie/online-coaching/cancel?token=${token}`,
      });
      const mailOptions = {
        from: process.env.MAIL_FROM,
        to: email,
        subject: "Subscription Cancellation",
        html: htmlToSend,
      };

      await transporter.sendMail(mailOptions);
      res.status(200);

      console.log("Cancellation email sent to:", email);
    } catch (error) {
      console.error("Error deleting subscription:", error);
      res.status(500).json({ error: "Failed to delete subscription" });
    }
  }
  public async confirmCancelSubscription(req: Request, res: Response) {
    const { token } = req.body;
    console.log("Token received:", token);
    try {
      const subscriber = await OnlineSubscriber.findOne({
        cancelToken: token,
      });
      if (!subscriber) {
        res.status(404).json({ error: "Subscriber not found" });
        return;
      }
      // Cancel the subscription
      const subscription = await stripe.subscriptions.cancel(
        subscriber.subscriptionId
      );
      // Delete the subscriber from the database
      await OnlineSubscriber.findOneAndUpdate(
        { cancelToken: token },
        { status: "canceled" }
      );

      res.status(200).json({ message: "Subscription cancelled successfully" });
    } catch (error) {
      console.error("Error confirming cancellation:", error);
      res.status(500).json({ error: "Failed to confirm cancellation" });
    }
  }
}

const readHTMLFile = (filePath: string) => {
  return fs.readFileSync(filePath, "utf8");
};

const generateToken = async (customerId: string) => {
  const token = await stripe.tokens.create({
    customer: customerId,
  });
  return token.id;
};

