import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';
import resend from '../config/resend';
import stripe from '../config/stripe';
import PaymentSession from '../models/PaymentSession';
import User from '../models/User';
import { sendNotificationToAdmin } from '../services/notification';

// Each Stripe webhook endpoint has its own signing secret; env vars allow
// rotation without a deploy, hardcoded values are the current live/dev secrets.
const endpointSecret =
  process.env.NODE_ENV == 'development'
    ? process.env.STRIPE_COACHING_WEBHOOK_SECRET_DEV ||
      'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
    : process.env.STRIPE_COACHING_WEBHOOK_SECRET ||
      'whsec_yIFQOy0GjJtbZSPfz1eO3IrO3qPBuozh';

const handleWebhook = async (req: Request, res: Response) => {
  const sig = req.headers['stripe-signature'];

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
    case 'checkout.session.expired': {
      const expired = event.data.object as any;
      console.log(
        'Checkout session expired:',
        expired.id,
        'customer:',
        expired.customer,
        'email:',
        expired.customer_email || expired.customer_details?.email
      );
      break;
    }
    case 'invoice.payment_failed': {
      const invoice = event.data.object as any;
      console.error(
        'Invoice payment failed:',
        invoice.id,
        'customer:',
        invoice.customer,
        'subscription:',
        invoice.subscription,
        'reason:',
        invoice.last_finalization_error?.message ||
          invoice.last_payment_error?.message ||
          'unknown'
      );
      break;
    }
    default:
  }

  res.status(200).json({ received: true });
};

const completeTransaction = async (event: any) => {
  const session = event.data.object;

  // Only process online coaching sessions
  if (session.metadata?.type !== 'online_coaching') {
    console.log('Skipping non-online-coaching session:', session.id);
    return;
  }

  const paymentSession = await PaymentSession.findOne({
    sessionId: session.id,
  });

  if (!paymentSession) {
    console.error('Payment session not found for:', session.id);
    return;
  }

  const subscription = event.data.object.subscription;
  const subStatus = (
    await stripe.subscriptions.retrieve(subscription! as string)
  ).status;

  // Sending mail (Waiting for designers to create templates)
  const template_path = path.join(
    process.cwd(),
    'templates',
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
