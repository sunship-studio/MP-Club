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
exports.dropStalePassTokenIndex = dropStalePassTokenIndex;
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
const mongoose_1 = __importDefault(require("mongoose"));
const database_1 = __importDefault(require("../config/database"));
const STALE_INDEX = 'token_1';
function dropStalePassTokenIndex() {
    return __awaiter(this, void 0, void 0, function* () {
        const collection = mongoose_1.default.connection.db.collection('classpasses');
        const indexes = yield collection.indexes();
        if (!indexes.some((index) => index.name === STALE_INDEX))
            return false;
        yield collection.dropIndex(STALE_INDEX);
        return true;
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        yield (0, database_1.default)();
        const dropped = yield dropStalePassTokenIndex();
        console.log(dropped
            ? `Dropped stale index ${STALE_INDEX} from classpasses.`
            : `No ${STALE_INDEX} index on classpasses — nothing to do.`);
        yield mongoose_1.default.disconnect();
    });
}
if (require.main === module) {
    main().catch((error) => {
        console.error('Failed to drop stale pass token index:', error);
        process.exit(1);
    });
}
