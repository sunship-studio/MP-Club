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
 * Backdate a pass so the expired-link path can be tested (D8).
 * Local databases only.
 *
 * Run: npm run dev:expire -- mary@example.com
 */
const mongoose_1 = __importDefault(require("mongoose"));
const database_1 = __importDefault(require("../config/database"));
const ClassPass_1 = __importDefault(require("../models/ClassPass"));
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b;
        const uri = (_a = process.env.MONGO_URI) !== null && _a !== void 0 ? _a : '';
        if (!/(127\.0\.0\.1|localhost)/.test(uri)) {
            throw new Error('dev:expire refuses to run against a non-local database.');
        }
        const email = (_b = process.argv[2]) === null || _b === void 0 ? void 0 : _b.trim().toLowerCase();
        if (!email)
            throw new Error('Usage: npm run dev:expire -- <email>');
        yield (0, database_1.default)();
        const pass = yield ClassPass_1.default.findOneAndUpdate({ email }, { $set: { validFromDate: '2025-01-01', validUntilDate: '2025-04-01' } }, { new: true, sort: { purchasedAt: -1 } });
        if (!pass) {
            console.log(`No pass found for ${email}`);
        }
        else {
            console.log(`Backdated ${email}: now ran ${pass.validFromDate} → ${pass.validUntilDate}`);
        }
        yield mongoose_1.default.disconnect();
    });
}
main().catch((error) => {
    var _a;
    console.error((_a = error.message) !== null && _a !== void 0 ? _a : error);
    process.exit(1);
});
