/**
 * Script to manually create an online coaching client in the database
 * Usage: npx ts-node scripts/create-coaching-client.ts
 *
 * Edit the CLIENT_DATA below before running
 */

import dotenv from 'dotenv';
import mongoose from 'mongoose';
import User from '../src/models/User';

dotenv.config();

const MONGO_USER = process.env.MONGO_USER!;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD!;
const MONGODB_URI = `mongodb+srv://${MONGO_USER}:${MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;

// ============================================
// EDIT THIS DATA BEFORE RUNNING THE SCRIPT
// ============================================
const CLIENT_DATA = {
  email: 'seankeenansk@live.co.uk',
  firstName: 'Sean',
  lastName: 'Keenan',
  age: 27,
  customerId: 'cus_XXXXXXXXXX', // Stripe customer ID
  subscriptionId: 'sub_XXXXXXXXXX', // Stripe subscription ID
  status: 'active', // 'active', 'canceled', 'past_due', etc.
};
// ============================================

async function createClient() {
  console.log('Connecting to MongoDB...');

  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  // Check if client already exists
  const existingUser = await User.findOne({ email: CLIENT_DATA.email });
  if (existingUser) {
    console.error('❌ User with this email already exists:', CLIENT_DATA.email);
    console.log('Existing user ID:', existingUser._id);
    await mongoose.disconnect();
    process.exit(1);
  }

  // Create the new user
  const newUser = await User.create({
    email: CLIENT_DATA.email,
    firstName: CLIENT_DATA.firstName,
    lastName: CLIENT_DATA.lastName,
    age: CLIENT_DATA.age,
    customerId: CLIENT_DATA.customerId,
    subscriptionId: CLIENT_DATA.subscriptionId,
    status: CLIENT_DATA.status,
    startDate: new Date(),
    type: 'online_coaching',
  });

  console.log('✅ Online coaching client created successfully!');
  console.log('User ID:', newUser._id);
  console.log('Email:', newUser.email);
  console.log('Name:', `${newUser.firstName} ${newUser.lastName}`);

  await mongoose.disconnect();
  console.log('Done!');
}

createClient().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
