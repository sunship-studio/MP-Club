/**
 * Throwaway data for local testing: a couple of recurring group classes plus
 * the pass product. Refuses to run against anything but a local database.
 *
 * Run: npm run seed:local
 */
import mongoose from 'mongoose';

import connectToDatabase from '../config/database';
import GroupClass from '../models/GroupClass';
import { seedClassPassProduct } from './seed_class_passes';

function assertLocal(): void {
  const uri = process.env.MONGO_URI ?? '';
  if (!/(127\.0\.0\.1|localhost)/.test(uri)) {
    throw new Error(
      'seed:local refuses to run: MONGO_URI is not a local database. ' +
        'This script creates throwaway classes and must never touch production.'
    );
  }
}

async function main(): Promise<void> {
  assertLocal();
  await connectToDatabase();

  await GroupClass.deleteMany({ title: { $regex: '^DEV ' } });

  const classes = await GroupClass.create([
    {
      title: 'DEV Strength & Conditioning',
      durationMinutes: 60,
      spotsAvailable: 8,
      recurring: true,
      dayOfWeek: 'Monday',
      timeSlots: [
        { time: '06:30 AM', spots: [] },
        { time: '06:30 PM', spots: [] },
      ],
    },
    {
      title: 'DEV Conditioning',
      durationMinutes: 45,
      spotsAvailable: 2, // small on purpose: makes "fully booked" easy to hit
      recurring: true,
      dayOfWeek: 'Wednesday',
      timeSlots: [{ time: '07:00 PM', spots: [] }],
    },
    {
      title: 'DEV Saturday Session',
      durationMinutes: 60,
      spotsAvailable: 10,
      recurring: true,
      dayOfWeek: 'Saturday',
      timeSlots: [{ time: '10:00 AM', spots: [] }],
    },
  ]);

  const product = await seedClassPassProduct();

  console.log(`Seeded ${classes.length} DEV group classes.`);
  console.log(
    `Seeded pass product: ${product.name} — ${product.months} months, ` +
      `€${(product.priceCents / 100).toFixed(2)}`
  );

  await mongoose.disconnect();
}

main().catch((error) => {
  console.error('Local seed failed:', error.message ?? error);
  process.exit(1);
});
