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
exports.PlanForSale = exports.PlanForSaleSchema = void 0;
const mongoose_1 = __importStar(require("mongoose"));
exports.PlanForSaleSchema = new mongoose_1.Schema({
    excelFileUrl: { type: String, required: true },
    lastUpdated: { type: Date },
    name: { type: String, required: true },
    days: [
        {
            lastUpdated: { type: Date },
            name: { type: String, required: true },
            exercises: [
                {
                    videoUrl: { type: String, required: false },
                    bodyParts: { type: [String], default: [] },
                    exerciseId: { type: String, required: true },
                    minutes: { type: Number, default: 0 },
                    seconds: { type: Number, default: 0 },
                    sets: [
                        {
                            reps: { type: String, required: true },
                            rir: { type: Number, required: true },
                            weight: { type: Number, required: true },
                        },
                    ],
                    name: { type: String, required: true },
                },
            ],
        },
    ],
    priceId: { type: String, required: true },
    price: { type: Number, required: true },
    stripeProductId: { type: String, required: true },
    bodyParts: { type: [String], default: [] },
}, { timestamps: true });
exports.PlanForSale = mongoose_1.default.model('PlanForSale', exports.PlanForSaleSchema);
