import { Request, Response } from "express";
import { sendNotificationToAdmin } from "../services/notificationsService";
import transporter from "../config/mailer";
import OnlineSubscriber from "../models/OnlineSubscriber";
import fs from "fs";
import PaymentSession from "../models/PaymentSession";
import stripe from "../config/stripe";
import path from "path";
import Handlebars from "handlebars";
const plans = [
  {
    type: "Push Pull Legs",
    price: 199.99,
    priceId: "price_1RGjVPPrBbVluHtKMSq17jrQ",
  },
  {
    type: "Upper Focused 4 Day Split",
    price: 199.99,
    priceId: "price_1RGjVtPrBbVluHtKMS8Gj0I5",
  },
  {
    type: "Female Lower Focused Split",
    price: 199.99,
    priceId: "price_1RGjQQPrBbVluHtKOJhsfoRW",
  },
  {
    type: "Lower Focused 4 Day Split",
    price: 199.99,
    priceId: "price_1RGjPmPrBbVluHtKAdUK720a",
  },
];

const handleBars = Handlebars.create();

const handleWebhook = async (req: Request, res: Response) => {
  const sig = req.headers["stripe-signature"];
  const endpointSecret =
    process.env.NODE_ENV == "development"
      ? "whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47"
      : process.env.STRIPE_WEBHOOK_SECRET;
  let event;
  if (!Buffer.isBuffer(req.body)) {
    console.error("Webhook Error: Request body is not a Buffer");
    return res.status(400).send("Webhook Error: Invalid request body format");
  }

  try {
    event = stripe.webhooks.constructEvent(
      req.body as Buffer,
      sig!,
      endpointSecret!
    );
  } catch (err) {
    console.error("Error verifying webhook signature:", err);
    return res.status(400).send(`Webhook Error: ${err}`);
  }

  // Handle the event
  switch (event.type) {
    case "checkout.session.completed":
      const session = await stripe.checkout.sessions.retrieve(
        event.data.object.id,
        {
          expand: ["line_items"],
        }
      );

      // Then you can access the priceId with:
      const lineItems = session.line_items?.data;
      console.log("Session data:", session);
      if (!lineItems || lineItems.length === 0) {
        console.error("No line items found in the session");
        return res.status(400).send("Webhook Error: No line items found");
      }
      const priceId = lineItems[0].price?.id;
      if (!priceId) {
        console.error("Price ID not found in the line item");
        return res.status(400).send("Webhook Error: Price ID not found");
      }

      if (priceId === process.env.STRIPE_PRICE_ID) {
        const paymentSession = await PaymentSession.findOne({
          sessionId: session.id,
        });
        const subscription = event.data.object.subscription;
        const subStatus = (
          await stripe.subscriptions.retrieve(subscription! as string)
        ).status;
        const template_path = path.join(
          __dirname,
          "templates",
          "online_success.html"
        );
        const templateSource = readHTMLFile(template_path);
        const template = handleBars.compile(templateSource);
        const htmlToSend = template({
          subtotal: "€200.00",
        });
        const mailOptions = {
          from: process.env.MAIL_FROM,
          to: paymentSession?.email,
          subject: "Subscription Confirmation",
          html: htmlToSend,
        };
        await transporter.sendMail(mailOptions);
        const subscriber = await OnlineSubscriber.create({
          email: paymentSession?.email,
          firstName: paymentSession?.firstName,
          lastName: paymentSession?.lastName,
          age: paymentSession?.age,
          customerId: session.customer,
          subscriptionId: session.subscription,
          status: subStatus,
          startDate: new Date(),
        });
        sendNotificationToAdmin(
          "New Online Coaching Subscription",
          `New subscription from ${paymentSession?.firstName} ${paymentSession?.lastName}`
        );
        console.log("Payment successful:", session);
      } else {
        const template_path = path.join(
          __dirname,
          '../..',
          "templates",
          "plan_order.html"
        );
        const templateSource = readHTMLFile(template_path);
        const template = handleBars.compile(templateSource);
        const htmlToSend = template({
          type:
            priceId === plans[0].priceId
              ? plans[0].type
              : priceId === plans[1].priceId
              ? plans[1].type
              : priceId === plans[2].priceId
              ? plans[2].type
              : plans[3].type,
          price: plans[0].price.toString(),
          subtotal: plans[0].price.toString(),
          orderDate: new Date().toLocaleDateString("en-US"),
          orderNumber: session.id,
        });
        const mailOptions = {
          from: process.env.MAIL_FROM,
          to: session.customer_email,
          subject: "Plan Order Confirmation",
          html: htmlToSend,
        };
      }

      break;
    case "checkout.session.async_payment_failed":
      console.log("Payment failed:", event.data.object);
      break;
    default:
      console.warn(`Unhandled event type: ${event.type}`);
  }

  res.status(200).json({ received: true });
};
const readHTMLFile = (filePath: string) => {
  return fs.readFileSync(filePath, "utf8");
};

export default handleWebhook;
