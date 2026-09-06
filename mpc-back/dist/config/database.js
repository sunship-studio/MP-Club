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
const dotenv_1 = __importDefault(require("dotenv"));
const mongoose_1 = __importDefault(require("mongoose"));
const ClassPass_1 = __importDefault(require("../models/ClassPass"));
dotenv_1.default.config();
// An explicit MONGO_URI wins, so a dev machine can point at a local mongod
// instead of the production cluster. Falls back to the Atlas cluster built
// from MONGO_USER / MONGO_PASSWORD when it isn't set.
const mongoURI = process.env.MONGO_URI ||
    `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;
/**
 * Bring the class-pass indexes in line with the schema.
 *
 * Mongoose only ever *adds* indexes, so a field that is removed leaves its
 * index behind. D16 deleted the pass `token` field but left `token_1` — unique
 * and not sparse — so every pass written since stored `token: null` and the
 * second one ever inserted was rejected:
 *
 *   E11000 duplicate key error ... index: token_1 dup key: { token: null }
 *
 * A paid customer silently not getting their pass is expensive enough that
 * this is worth doing on every boot rather than trusting a migration to be run.
 * `syncIndexes` also drops indexes added by hand in Atlas, which is the trade:
 * for this collection the schema is the only thing that should define them.
 */
function syncPassIndexes() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const dropped = yield ClassPass_1.default.syncIndexes();
            if (dropped.length > 0) {
                console.log('Dropped stale class pass indexes:', dropped.join(', '));
            }
        }
        catch (error) {
            // Never fatal: a running server that cannot reindex is still a server, and
            // the failure needs to be visible rather than take the boot down with it.
            console.error('Could not sync class pass indexes:', error);
        }
    });
}
const connectToDatabase = () => __awaiter(void 0, void 0, void 0, function* () {
    // Never log the URI: it carries the cluster credentials.
    console.log('Connecting to MongoDB...');
    if (!process.env.MONGO_URI && (!process.env.MONGO_USER || !process.env.MONGO_PASSWORD)) {
        console.error('MongoDB credentials are not set in environment variables.');
        return;
    }
    try {
        yield mongoose_1.default.connect(mongoURI);
        console.log('Connected to MongoDB: ' +
            (process.env.MONGO_URI ? 'local//explicit MONGO_URI' : 'Atlas cluster'));
        yield syncPassIndexes();
    }
    catch (error) {
        console.error('Error connecting to MongoDB:', error);
    }
});
exports.default = connectToDatabase;
