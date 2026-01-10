import Stripe from 'stripe';

// Initialize Stripe
const stripe = new Stripe(
  process.env.NODE_ENV === 'development'
    ? process.env.STRIPE_TEST_SECRET_KEY!
    : process.env.STRIPE_SECRET_KEY!
);

export default stripe;
