import { Request, Response } from 'express';
import Stripe from 'stripe';
import { groupClassController } from '../routes/group_classes';

const stripe = new Stripe(
  process.env.NODE_ENV === 'development'
    ? process.env.STRIPE_TEST_SECRET_KEY!
    : process.env.STRIPE_SECRET_KEY!
);

// Webhook endpoint secret - you'll need to set this up in Stripe dashboard
const endpointSecret =
  process.env.NODE_ENV === 'development'
    ? 'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
    : 'whsec_M8tsimlpTL3EclroIrWp6NRmiYddUNtO';

export const handleGroupClassWebhook = async (
  req: Request,
  res: Response
): Promise<void> => {
  const sig = req.headers['stripe-signature'];

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig!, endpointSecret);
  } catch (err: any) {
    console.error('⚠️ Webhook signature verification failed:', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  // Handle the checkout.session.completed event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;

    console.log('✅ Group class payment completed:', session.id);

    // Extract metadata
    const metadata = session.metadata;
    if (!metadata) {
      console.error('No metadata found in session');
      res.status(400).send('No metadata found');
      return;
    }

    const {
      classId,
      timeSlot,
      firstName,
      lastName,
      email,
      date,
      className,
      durationMinutes,
    } = metadata;

    try {
      // Confirm the booking
      await groupClassController.confirmBookingAfterPayment(
        classId,
        timeSlot,
        firstName,
        lastName || '',
        email,
        date,
        className,
        parseInt(durationMinutes, 10)
      );

      console.log('✅ Booking confirmed for:', email);
    } catch (error) {
      console.error('Error confirming booking:', error);
      // Don't return error - Stripe will retry
    }
  }

  res.status(200).json({ received: true });
};
