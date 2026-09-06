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
 * Throwaway data for local testing: a couple of recurring group classes plus
 * the pass product. Refuses to run against anything but a local database.
 *
 * Run: npm run seed:local
 */
const mongoose_1 = __importDefault(require("mongoose"));
const database_1 = __importDefault(require("../config/database"));
const GroupClass_1 = __importDefault(require("../models/GroupClass"));
const seed_class_passes_1 = require("./seed_class_passes");
function assertLocal() {
    var _a;
    const uri = (_a = process.env.MONGO_URI) !== null && _a !== void 0 ? _a : '';
    if (!/(127\.0\.0\.1|localhost)/.test(uri)) {
        throw new Error('seed:local refuses to run: MONGO_URI is not a local database. ' +
            'This script creates throwaway classes and must never touch production.');
    }
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        assertLocal();
        yield (0, database_1.default)();
        yield GroupClass_1.default.deleteMany({ title: { $regex: '^DEV ' } });
        const classes = yield GroupClass_1.default.create([
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
        const product = yield (0, seed_class_passes_1.seedClassPassProduct)();
        console.log(`Seeded ${classes.length} DEV group classes.`);
        console.log(`Seeded pass product: ${product.name} — ${product.months} months, ` +
            `€${(product.priceCents / 100).toFixed(2)}`);
        yield mongoose_1.default.disconnect();
    });
}
main().catch((error) => {
    var _a;
    console.error('Local seed failed:', (_a = error.message) !== null && _a !== void 0 ? _a : error);
    process.exit(1);
});
