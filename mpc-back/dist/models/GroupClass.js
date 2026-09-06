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
const GroupClassSchema = new mongoose_1.Schema({
    title: { type: String, required: true },
    durationMinutes: { type: Number, required: true },
    timeSlots: {
        type: [
            {
                time: { type: String, required: true },
                spots: [
                    {
                        id: { type: mongoose_1.Schema.Types.ObjectId },
                        email: { type: String, required: true },
                        bookedAt: { type: Date, default: Date.now },
                        firstName: { type: String, required: true },
                        lastName: { type: String, required: false },
                        occurrenceDate: { type: String, required: false },
                        status: {
                            type: String,
                            enum: ['pending', 'confirmed'],
                            default: 'confirmed',
                        },
                        // Defaults false so bookings made before this existed read as paid,
                        // which is the conservative answer: they are not self-cancellable.
                        bookedWithPass: { type: Boolean, default: false },
                        holdId: { type: String, required: false },
                        holdExpiresAt: { type: Date, required: false },
                    },
                ],
            },
        ],
        required: true,
    },
    date: { type: Date, required: false, index: true },
    spotsAvailable: { type: Number, required: true },
    recurring: { type: Boolean, default: false },
    dayOfWeek: { type: String, required: false },
});
const GroupClass = mongoose_1.default.model('GroupClass', GroupClassSchema);
exports.default = GroupClass;
