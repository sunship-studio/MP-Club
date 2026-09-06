/**
 * Drop the `token_1` index left behind by D16.
 *
 * Passes used to carry a bearer token, uniquely indexed. D16 replaced that with
 * a customer account, and the field went away — but the index did not, because
 * mongoose only ever adds indexes, never removes them. It is unique and *not*
 * sparse, so every pass written since stores `token: null` and the second one
 * ever collides with the first:
 *
 *   E11000 duplicate key error ... index: token_1 dup key: { token: null }
 *
 * That surfaces as a paid customer never getting their pass, so this has to run
 * against production before the D16 code is deployed there.
 *
 * Run: npx ts-node src/scripts/drop_stale_pass_token_index.ts
 */
import mongoose from 'mongoose';

import connectToDatabase from '../config/database';

const STALE_INDEX = 'token_1';

export async function dropStalePassTokenIndex(): Promise<boolean> {
  const collection = mongoose.connection.db!.collection('classpasses');

  const indexes = await collection.indexes();
  if (!indexes.some((index) => index.name === STALE_INDEX)) return false;

  await collection.dropIndex(STALE_INDEX);
  return true;
}

async function main(): Promise<void> {
  await connectToDatabase();
  const dropped = await dropStalePassTokenIndex();
  console.log(
    dropped
      ? `Dropped stale index ${STALE_INDEX} from classpasses.`
      : `No ${STALE_INDEX} index on classpasses — nothing to do.`
  );
  await mongoose.disconnect();
}

if (require.main === module) {
  main().catch((error) => {
    console.error('Failed to drop stale pass token index:', error);
    process.exit(1);
  });
}
