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
exports.DEFAULT_PASS_PRODUCT = exports.LEGACY_QUARTERLY_PASS_PRODUCT = exports.MONTHLY_PASS_PRODUCT = void 0;
exports.seedClassPassProduct = seedClassPassProduct;
exports.retirePassProduct = retirePassProduct;
/**
 * Seeds the sellable class-pass products.
 *
 * Products are seeded rather than admin-editable (D11): pricing changes twice a
 * year at most, so a product-editor screen is the expensive half of the admin
 * work for the least return.
 *
 * Run: npx ts-node src/scripts/seed_class_passes.ts
 */
const mongoose_1 = __importDefault(require("mongoose"));
const database_1 = __importDefault(require("../config/database"));
const ClassPassProduct_1 = __importDefault(require("../models/ClassPassProduct"));
/**
 * €90 a month, sellable recurring — what Shane asked for on 2026-09-04 (D17).
 */
exports.MONTHLY_PASS_PRODUCT = {
    name: '1 Month Unlimited',
    months: 1,
    priceCents: 9000,
    currency: 'eur',
    allowSubscription: true,
};
/**
 * The pass this feature launched with. Off sale since D17, and kept here only
 * so the retirement is expressed as data rather than a hand-typed name.
 */
exports.LEGACY_QUARTERLY_PASS_PRODUCT = {
    name: '3 Months Unlimited',
    months: 3,
    priceCents: 30000,
    currency: 'eur',
};
/** What `seedClassPassProduct()` puts on sale when asked for nothing specific. */
exports.DEFAULT_PASS_PRODUCT = exports.MONTHLY_PASS_PRODUCT;
/**
 * Put a product on sale, superseding any earlier version of it.
 *
 * A price change never edits an existing product: passes reference the product
 * they were sold under, and a €300 pass must keep pointing at a €300 product
 * however the price moves afterwards. So the old row is taken off sale and a
 * new one created. Re-running with an unchanged spec is a no-op.
 */
function seedClassPassProduct() {
    return __awaiter(this, arguments, void 0, function* (spec = exports.DEFAULT_PASS_PRODUCT) {
        var _a;
        const allowSubscription = (_a = spec.allowSubscription) !== null && _a !== void 0 ? _a : false;
        const existing = yield ClassPassProduct_1.default.findOne({
            name: spec.name,
            months: spec.months,
            priceCents: spec.priceCents,
            currency: spec.currency,
        });
        // Only one version of a given pass is ever on sale at a time.
        yield ClassPassProduct_1.default.updateMany(existing
            ? { name: spec.name, _id: { $ne: existing._id } }
            : { name: spec.name }, { $set: { active: false } });
        if (existing) {
            // Billing mode is not a price, so flipping it edits the product in place
            // rather than superseding it: passes already sold under it are unaffected.
            if (!existing.active || existing.allowSubscription !== allowSubscription) {
                existing.active = true;
                existing.allowSubscription = allowSubscription;
                yield existing.save();
            }
            return existing;
        }
        return ClassPassProduct_1.default.create(Object.assign(Object.assign({}, spec), { allowSubscription, active: true }));
    });
}
/**
 * Take a product off sale by name. Never deletes: a pass references the product
 * it was sold under, and a €300 pass must keep resolving its own name however
 * the catalogue moves on. Returns how many rows it retired.
 */
function retirePassProduct(name) {
    return __awaiter(this, void 0, void 0, function* () {
        const result = yield ClassPassProduct_1.default.updateMany({ name, active: true }, { $set: { active: false } });
        return result.modifiedCount;
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        yield (0, database_1.default)();
        const product = yield seedClassPassProduct();
        console.log(`Seeded pass product: ${product.name} — ${product.months} months, ` +
            `${(product.priceCents / 100).toFixed(2)} ${product.currency.toUpperCase()}` +
            `${product.allowSubscription ? ' (recurring available)' : ''}`);
        const retired = yield retirePassProduct(exports.LEGACY_QUARTERLY_PASS_PRODUCT.name);
        if (retired > 0) {
            console.log(`Took off sale: ${exports.LEGACY_QUARTERLY_PASS_PRODUCT.name}`);
        }
        yield mongoose_1.default.disconnect();
    });
}
if (require.main === module) {
    main().catch((error) => {
        console.error('Failed to seed class pass products:', error);
        process.exit(1);
    });
}
