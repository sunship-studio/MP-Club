/**
 * Backdate a pass so the expired-link path can be tested (D8).
 * Local databases only.
 *
 * Run: npm run dev:expire -- mary@example.com
 */
import mongoose from 'mongoose';

import connectToDatabase from '../config/database';
import ClassPass from '../models/ClassPass';

async function main(): Promise<void> {
  const uri = process.env.MONGO_URI ?? '';
  if (!/(127\.0\.0\.1|localhost)/.test(uri)) {
    throw new Error('dev:expire refuses to run against a non-local database.');
  }

  const email = process.argv[2]?.trim().toLowerCase();
  if (!email) throw new Error('Usage: npm run dev:expire -- <email>');

  await connectToDatabase();

  const pass = await ClassPass.findOneAndUpdate(
    { email },
    { $set: { validFromDate: '2025-01-01', validUntilDate: '2025-04-01' } },
    { new: true, sort: { purchasedAt: -1 } }
  );

  if (!pass) {
    console.log(`No pass found for ${email}`);
  } else {
    console.log(`Backdated ${email}: now ran ${pass.validFromDate} → ${pass.validUntilDate}`);
  }

  await mongoose.disconnect();
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exit(1);
});
