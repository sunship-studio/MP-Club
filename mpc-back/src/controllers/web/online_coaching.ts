import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

import stripe from '../../config/stripe';
import PaymentSession from '../../models/PaymentSession';
import OnlineSubscriber from '../../models/User';

const STRIPE_SESSION_TTL_S = 30 * 60; // Stripe minimum is 30 min

export default class OnlineCoachingController {
  constructor() {
    // Initialize any properties or dependencies here
  }

  async createCheckoutSession(req: Request, res: Response) {
    console.log('Creating checkout session...');
    console.log('Request body:', req.body);
    const { email, firstName, lastName, age } = req.body;

    try {
      if (!email) {
        res.status(400).json({ error: 'Email is required' });
        return;
      }

      // Reuse one Stripe Customer per email. Anonymous sessions mint a fresh
      // customer on every retry, which Radar scores as escalating fraud risk.
      let customerId: string | undefined;
      try {
        const existing = await stripe.customers.list({ email, limit: 1 });
        customerId =
          existing.data[0]?.id ??
          (
            await stripe.customers.create({
              email,
              name: [firstName, lastName].filter(Boolean).join(' ') || undefined,
            })
          ).id;
      } catch (customerError) {
        console.error('Error resolving Stripe customer:', customerError);
      }

      const session = await stripe.checkout.sessions.create({
        expires_at: Math.floor(Date.now() / 1000) + STRIPE_SESSION_TTL_S,
        payment_method_types: ['card'],
        payment_method_options: {
          card: {
            request_three_d_secure: 'any',
          },
        },
        mode: 'subscription',
        ...(customerId ? { customer: customerId } : { customer_email: email }),
        billing_address_collection: 'required',
        line_items: [
          {
            price:
              process.env.NODE_ENV == 'production'
                ? process.env.STRIPE_PRICE_ID
                : process.env.STRIPE_TEST_PRICE_ID,
            quantity: 1,
          },
        ],
        metadata: {
          type: 'online_coaching',
        },
        success_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/online-coaching/success`
            : `https://www.midlandsperformanceclub.ie/online-coaching/success`,
        cancel_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/online-coaching/`
            : `https://www.midlandsperformanceclub.ie/online-coaching/`,
      });
      console.log('Session created:', session);
      // Store the session ID in your database or perform any other necessary actions
      await PaymentSession.create({
        sessionId: session.id,
        email,
        firstName,
        lastName,
        age,
        customerId,
      })
        .then(() => {
          console.log('Payment session saved to database');
        })
        .catch((error) => {
          console.error('Error saving payment session:', error);
        });

      res.status(200).json({
        url: session.url,
      });
    } catch (error) {
      console.error('Error creating subscription:', error);
      const message =
        error instanceof Error ? error.message : 'Failed to create subscription';
      res.status(500).json({ error: message });
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
        res.status(404).json({ error: 'Customer not found' });
      }
      // Token generation
      const token = await generateToken(customer.data[0].id);
      const subscriber = await OnlineSubscriber.findOneAndUpdate(
        { email: email },
        { cancelToken: token }
      );
      // Template emails
      const template_path = path.join(
        process.cwd(),
        'templates',
        'online_cancelation.html'
      );
      const templateSource = readHTMLFile(template_path);
      const template = Handlebars.compile(templateSource);
      const htmlToSend = template({
        cancelUrl: `midlandsperformanceclub.ie/online-coaching/cancel?token=${token}`,
      });
      const mailOptions = {
        from: process.env.MAIL_FROM,
        to: email,
        subject: 'Subscription Cancellation',
        html: htmlToSend,
      };

      res.status(200);

      console.log('Cancellation email sent to:', email);
    } catch (error) {
      console.error('Error deleting subscription:', error);
      res.status(500).json({ error: 'Failed to delete subscription' });
    }
  }
  public async confirmCancelSubscription(req: Request, res: Response) {
    const { token } = req.body;
    console.log('Token received:', token);
    try {
      const subscriber = await OnlineSubscriber.findOne({
        cancelToken: token,
      });
      if (!subscriber) {
        res.status(404).json({ error: 'Subscriber not found' });
        return;
      }
      // Cancel the subscription
      const subscription = await stripe.subscriptions.cancel(
        subscriber.subscriptionId
      );
      // Delete the subscriber from the database
      await OnlineSubscriber.findOneAndUpdate(
        { cancelToken: token },
        { status: 'canceled' }
      );

      res.status(200).json({ message: 'Subscription cancelled successfully' });
    } catch (error) {
      console.error('Error confirming cancellation:', error);
      res.status(500).json({ error: 'Failed to confirm cancellation' });
    }
  }
}

const readHTMLFile = (filePath: string) => {
  return fs.readFileSync(filePath, 'utf8');
};

const generateToken = async (customerId: string) => {
  const token = await stripe.tokens.create({
    customer: customerId,
  });
  return token.id;
};
