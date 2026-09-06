"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importStar(require("mongoose"));
const ClassPassSchema = new mongoose_1.Schema({
    email: { type: String, required: true, index: true },
    firstName: { type: String, required: true },
    lastName: { type: String, required: false },
    productId: { type: mongoose_1.Schema.Types.ObjectId, ref: 'ClassPassProduct', required: true },
    months: { type: Number, required: true },
    pricePaidCents: { type: Number, required: true },
    validFromDate: { type: String, required: true },
    validUntilDate: { type: String, required: true },
    revoked: { type: Boolean, required: true, default: false },
    purchasedAt: { type: Date, required: true, default: Date.now },
    // Unique when present, so a replayed Stripe webhook cannot mint a second
    // pass for the same checkout session (D14).
    stripeSessionId: { type: String, required: false, unique: true, sparse: true },
    grantedByAdmin: { type: Boolean, required: true, default: false },
    // Unique when present: one pass per subscription, so a renewal can find the
    // pass it belongs to without ambiguity.
    stripeSubscriptionId: { type: String, required: false, unique: true, sparse: true },
    autoRenew: { type: Boolean, required: true, default: false },
    subscriptionStatus: {
        type: String,
        required: false,
        enum: ['active', 'canceling', 'canceled'],
    },
    nextChargeDate: { type: String, required: false },
    consumedInvoiceIds: { type: [String], required: true, default: [] },
});
const ClassPass = mongoose_1.default.model('ClassPass', ClassPassSchema);
exports.default = ClassPass;
