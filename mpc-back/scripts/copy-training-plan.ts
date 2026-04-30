/**
 * Script to copy a training plan from one user to another for testing
 * Usage: npx ts-node scripts/copy-training-plan.ts
 *
 * Edit SOURCE_USER_ID and TARGET_USER_ID below before running
 */

import dotenv from 'dotenv';
import mongoose from 'mongoose';
import User from '../src/models/User';

dotenv.config();

const MONGO_USER = process.env.MONGO_USER!;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD!;
const MONGODB_URI = `mongodb+srv://${MONGO_USER}:${MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;

// ============================================
// EDIT THESE IDs BEFORE RUNNING
// ============================================
const SOURCE_USER_ID = '69a8298cef7b389bcab704e5'; // Sean Keenan
const TARGET_USER_ID = '6901f042f3f0b3717cd13017'; // Apple Review (test account)
// ============================================

async function copyTrainingPlan() {
  console.log('Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);
  console.log('Connected to MongoDB');

  const sourceUser = await User.findById(SOURCE_USER_ID);
  if (!sourceUser) throw new Error(`Source user ${SOURCE_USER_ID} not found`);

  const targetUser = await User.findById(TARGET_USER_ID);
  if (!targetUser) throw new Error(`Target user ${TARGET_USER_ID} not found`);

  if (!sourceUser.trainingPlan?.days?.length) {
    throw new Error('Source user has no training plan');
  }

  // Deep copy to strip Mongoose internals
  const planCopy = JSON.parse(JSON.stringify(sourceUser.trainingPlan));
  planCopy.lastUpdated = new Date();
  planCopy.name = `Plan for ${targetUser.firstName}`;

  targetUser.trainingPlan = planCopy;
  await targetUser.save();

  console.log(
    `Copied training plan from ${sourceUser.firstName} ${sourceUser.lastName} -> ${targetUser.firstName} ${targetUser.lastName}`
  );
  console.log(
    `  Days: ${planCopy.days.length}, Exercises: ${planCopy.days.reduce((sum: number, d: any) => sum + d.exercises.length, 0)}`
  );

  await mongoose.disconnect();
  console.log('Done');
}

copyTrainingPlan().catch((err) => {
  console.error('Error:', err);
  mongoose.disconnect();
  process.exit(1);
});
