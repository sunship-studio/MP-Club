import { Request, Response } from 'express';
import stripe from '../../config/stripe';
import { PlanForSale } from '../../models/PlanForSale';
export default class PlansController {
  constructor() {}

  async getPlans(req: Request, res: Response) {
    try {
      // Get all training plans from database
      const trainingPlans = await PlanForSale.find();

      res.status(200).json(trainingPlans);
    } catch (error) {
      console.error('Error fetching training plans:', error);
      res.status(500).json({ error: 'Failed to fetch training plans' });
    }
  }

  async createCheckoutSession(req: Request, res: Response) {
    console.log('Creating checkout session...');
    console.log('Request body:', req.body);
    const { priceId } = req.body;
    console.log('Price ID:', priceId);

    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        payment_method_options: {
          card: {
            request_three_d_secure: 'any',
          },
        },
        mode: 'payment',
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        success_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/plans/success`
            : `${req.protocol}://${req.get('host')}/plans/success`,
        cancel_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/plans/`
            : `${req.protocol}://${req.get('host')}/plans/`,
      });
      console.log('Session created:', session);
      // Store the session ID in your database or perform any other necessary actions

      res.status(200).json({
        url: session.url,
      });
    } catch (error) {
      console.error('Error creating subscription:', error);
      res.status(500).json({ error: 'Failed to create subscription' });
    }
  }
}
