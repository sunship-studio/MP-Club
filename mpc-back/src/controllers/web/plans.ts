import { Request, Response } from 'express';
import stripe from '../../config/stripe';
import { TrainingPlan } from '../../models/TrainingPlan';
export default class PlansController {
  constructor() {}

  async getPlans(req: Request, res: Response) {
    try {
      // Get all training plans from database
      const trainingPlans = await TrainingPlan.find();

      // Fetch price information from Stripe for each plan
      const plansWithPrices = await Promise.all(
        trainingPlans.map(async (plan) => {
          try {
            // Get the product from Stripe
            const product = await stripe.products.retrieve(
              plan.stripeProductId
            );

            // Get prices for this product
            const prices = await stripe.prices.list({
              product: plan.stripeProductId,
              active: true,
            });

            const price = prices.data[0]; // Get the first active price

            return {
              id: plan._id,
              name: plan.name,
              excelFileUrl: plan.excelFileUrl,
              listOfExercises: plan.listOfExercises,
              stripeProductId: plan.stripeProductId,
              price:
                price && price.unit_amount ? price.unit_amount / 100 : null, // Convert from cents
              currency: price ? price.currency : null,
              priceId: price ? price.id : null,
            };
          } catch (error) {
            console.error(
              `Error fetching Stripe data for plan ${plan._id}:`,
              error
            );
            // Return plan without price data if Stripe fetch fails
            return {
              id: plan._id,
              name: plan.name,
              excelFileUrl: plan.excelFileUrl,
              listOfExercises: plan.listOfExercises,
              stripeProductId: plan.stripeProductId,
              price: null,
              currency: null,
              priceId: null,
            };
          }
        })
      );

      res.status(200).json(plansWithPrices);
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
