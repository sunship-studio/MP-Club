import sgMail from "@sendgrid/mail";
import { Request, Response } from "express";
import fs from "fs";
import path from "path";
import stripe from "stripe";
sgMail.setApiKey(process.env.SENDGRID_API_KEY!);


const Stripe = new stripe.Stripe(
process.env.NODE_ENV == "development" ? process.env.STRIPE_TEST_SECRET_KEY! : process.env.STRIPE_SECRET_KEY!,

);




// Test Stripe Products

const testTrainingPlans = [
  {
    priceId : "price_1RGjQQPrBbVluHtKOJhsfoRW",
    type: "femaleLower",
  }
  ,
  {
    priceId : "price_1RGjVtPrBbVluHtKMS8Gj0I5",
    type: "upper",
  },
  {
    priceId : "price_1RGjPmPrBbVluHtKAdUK720a",
    type: "lower",
  },
  {
    priceId : "price_1RGjVPPrBbVluHtKMSq17jrQ",
    type: "ppl",
  }
]

export const handlePlanWebhook = async (req: Request, res: Response) => {
  const sig = req.headers["stripe-signature"];
    const endpointSecret =
      process.env.NODE_ENV == "development"
        ? "whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47"
        : process.env.STRIPE_WEBHOOK_SECRET;
    let event;

    try {
      event = stripe.webhooks.constructEvent(req.body, sig!, endpointSecret!);
    } catch (err) {
      console.error("Error verifying webhook signature:", err);
       res.status(400).send(`Webhook Error: ${err}`);
    }

    // Handle the event
    switch (event!.type) {
      case "checkout.session.completed":
        try {      completeTransaction(event);} catch (error) {
          console.error('Error completing transaction:', error);
          res.status(500).send('Internal Server Error');
          return;
        }

        break;
      case "checkout.session.async_payment_failed":
        console.log("Payment failed:", event.data.object);
        break;
      default:

    }

    res.status(200).json({ received: true });
}

async function completeTransaction(event: stripe.Event) {
  const session = event.data.object as stripe.Checkout.Session;

  console.log('✅ Checkout Session Completed:', session.id);
  const lineItems = await Stripe.checkout.sessions.listLineItems(
    session.id,
    { limit: 1 }
  );
  console.log('🛒 Line Items:', lineItems.data);
  const priceId = (lineItems.data[0].price as stripe.Price).id;
  console.log('PRICE ID:', priceId);
  const type = testTrainingPlans.find(plan => plan.priceId === priceId)?.type || 'unknown';
  console.log(`🏷️  Purchased Plan Type: ${type}`)
  await sendTrainingPlanEmail(
    session.customer_details?.email || '',
    type,
    session.id,
  );
  console.log('✅ Training plan email sent to:', session.customer_details?.email);

 }


   export async function sendTrainingPlanEmail(
  email : string,
  planType : string,
  orderNumber : string,

 ) {

    const template_path = path.join(
    __dirname,
    "../",
    "templates",
    "training_plan.html"
  );

  const templateSource = fs.readFileSync(template_path, "utf8");

  let html = templateSource.replace("{{planDownloadLink}}", `https://mp-club-production.up.railway.app/web/plans/download-training-plan/${planType}/${process.env.TRAINING_PLAN_DOWNLOAD_TOKEN}`);
  html = html.replace("{{orderNumber}}", orderNumber);

  const msg = {
    to: email,
    from: "shanemahon@midlandsperformanceclub.ie",
    subject: "Your Training Plan is Here!",
html:   html,
  };
  await sgMail.send(msg);

 }

