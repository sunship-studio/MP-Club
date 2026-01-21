import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';
import Stripe from 'stripe';
import resend from '../config/resend';
import PaymentSession from '../models/PaymentSession';
import User from '../models/User';
import { sendNotificationToAdmin } from '../services/notification';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {});

const handleWebhook = async (req: Request, res: Response) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret =
    process.env.NODE_ENV == 'development'
      ? 'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
      : 'whsec_yIFQOy0GjJtbZSPfz1eO3IrO3qPBuozh';
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig!, endpointSecret!);
  } catch (err) {
    console.error('Error verifying webhook signature:', err);
    return res.status(400).send(`Webhook Error: ${err}`);
  }

  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      completeTransaction(event);
      break;
    case 'checkout.session.async_payment_failed':
      console.log('Payment failed:', event.data.object);
      break;
    default:
  }

  res.status(200).json({ received: true });
};

const completeTransaction = async (event: any) => {
  const session = event.data.object;
  const paymentSession = await PaymentSession.findOne({
    sessionId: session.id,
  });
  const subscription = event.data.object.subscription;
  const subStatus = (
    await stripe.subscriptions.retrieve(subscription! as string)
  ).status;

  // Sending mail (Waiting for designers to create templates)
  const template_path = path.join(
    __dirname,
    '../templates',
    'online_coaching_confirmation.html'
  );
  const templateSource = readHTMLFile(template_path);

  const htmlContent = templateSource.replace(
    '{{firstName}}',
    paymentSession?.firstName || ''
  );

  const { data, error } = await resend.emails.send({
    from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
    to: [paymentSession?.email || ''],
    subject: 'Subscription Confirmation',
    html: htmlContent,
  });

  if (error) {
    console.error('Error sending email:', error);
  } else {
    console.log('✅ Email sent successfully:', data);
  }
  const subscriber = await User.create({
    email: paymentSession?.email,
    firstName: paymentSession?.firstName,
    lastName: paymentSession?.lastName,
    age: paymentSession?.age,
    customerId: session.customer,
    subscriptionId: session.subscription,
    status: subStatus,
    startDate: new Date(),
    type: 'online_coaching',
  });
  sendNotificationToAdmin(
    'New Online Coaching Subscription',
    `New subscription from ${paymentSession?.firstName} ${paymentSession?.lastName}`
  );
  console.log('Payment successful:', session);
};

const readHTMLFile = (filePath: string) => {
  return fs.readFileSync(filePath, 'utf8');
};

export { handleWebhook };
