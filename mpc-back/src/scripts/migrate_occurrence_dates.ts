/**
 * One-time / repeatable migration: stamp each group-class booking onto the
 * occurrence it was actually made for (derived from `bookedAt`), and mark
 * legacy bookings confirmed.
 *
 * This supersedes the original migration, which stamped every legacy booking
 * onto the upcoming occurrence and so blocked re-booking. See
 * `repairOccurrenceDates` for the safe, idempotent logic.
 *
 * Run once against production: npx ts-node src/scripts/migrate_occurrence_dates.ts
 */
import dotenv from 'dotenv';
import mongoose from 'mongoose';

import GroupClass from '../models/GroupClass';
import { repairOccurrenceDates } from '../services/occurrence_repair';
dotenv.config();

// Same connection the app uses (config/database.ts), with a MONGO_URI override.
const mongoURI =
  process.env.MONGO_URI ||
  `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;

async function main() {
  await mongoose.connect(mongoURI);
  const { stamped } = await repairOccurrenceDates(GroupClass);
  console.log(`Done. Re-stamped occurrenceDate on ${stamped} legacy spot(s).`);
  await mongoose.disconnect();
}
main().catch((e) => {
  console.error(e);
  process.exit(1);
});
