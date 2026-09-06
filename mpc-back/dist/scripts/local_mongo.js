"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * A local mongod for development, so a dev server is never pointed at the
 * production Atlas cluster. Data persists in `.local-mongo/` between runs.
 *
 * Run: npm run mongo:local   (leave it running, then start the API)
 */
const path_1 = __importDefault(require("path"));
const fs_1 = require("fs");
const mongodb_memory_server_1 = require("mongodb-memory-server");
const PORT = 27017;
const DB_PATH = path_1.default.join(__dirname, '../../.local-mongo');
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        (0, fs_1.mkdirSync)(DB_PATH, { recursive: true });
        const mongod = yield mongodb_memory_server_1.MongoMemoryServer.create({
            instance: { port: PORT, dbPath: DB_PATH, storageEngine: 'wiredTiger' },
        });
        console.log(`Local mongo running at ${mongod.getUri()}`);
        console.log(`Data directory: ${DB_PATH}`);
        console.log('Leave this running. Ctrl-C to stop.');
        const stop = () => __awaiter(this, void 0, void 0, function* () {
            yield mongod.stop();
            process.exit(0);
        });
        process.on('SIGINT', stop);
        process.on('SIGTERM', stop);
    });
}
main().catch((error) => {
    console.error('Failed to start local mongo:', error);
    process.exit(1);
});
