/**
 * A local mongod for development, so a dev server is never pointed at the
 * production Atlas cluster. Data persists in `.local-mongo/` between runs.
 *
 * Run: npm run mongo:local   (leave it running, then start the API)
 */
import path from 'path';
import { mkdirSync } from 'fs';

import { MongoMemoryServer } from 'mongodb-memory-server';

const PORT = 27017;
const DB_PATH = path.join(__dirname, '../../.local-mongo');

async function main(): Promise<void> {
  mkdirSync(DB_PATH, { recursive: true });

  const mongod = await MongoMemoryServer.create({
    instance: { port: PORT, dbPath: DB_PATH, storageEngine: 'wiredTiger' },
  });

  console.log(`Local mongo running at ${mongod.getUri()}`);
  console.log(`Data directory: ${DB_PATH}`);
  console.log('Leave this running. Ctrl-C to stop.');

  const stop = async () => {
    await mongod.stop();
    process.exit(0);
  };
  process.on('SIGINT', stop);
  process.on('SIGTERM', stop);
}

main().catch((error) => {
  console.error('Failed to start local mongo:', error);
  process.exit(1);
});
