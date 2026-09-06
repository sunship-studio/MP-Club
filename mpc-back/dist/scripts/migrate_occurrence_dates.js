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
const dotenv_1 = __importDefault(require("dotenv"));
const mongoose_1 = __importDefault(require("mongoose"));
const GroupClass_1 = __importDefault(require("../models/GroupClass"));
const occurrence_repair_1 = require("../services/occurrence_repair");
dotenv_1.default.config();
// Same connection the app uses (config/database.ts), with a MONGO_URI override.
const mongoURI = process.env.MONGO_URI ||
    `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        yield mongoose_1.default.connect(mongoURI);
        const { stamped } = yield (0, occurrence_repair_1.repairOccurrenceDates)(GroupClass_1.default);
        console.log(`Done. Re-stamped occurrenceDate on ${stamped} legacy spot(s).`);
        yield mongoose_1.default.disconnect();
    });
}
main().catch((e) => {
    console.error(e);
    process.exit(1);
});
