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
const UserSchema = new mongoose_1.Schema({
    profilePictureUrl: { type: String },
    customerId: { type: String, required: true },
    subscriptionId: { type: String, required: true },
    status: { type: String, required: true },
    startDate: { type: Date, default: Date.now },
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    email: { type: String, required: true },
    age: { type: Number, required: true },
    token: { type: String },
    targetWeight: { type: Number },
    refreshToken: { type: String },
    fcmToken: { type: String }, // Firebase Cloud Messaging token
    checkIns: [
        {
            id: { type: mongoose_1.Schema.Types.ObjectId },
            date: { type: Date, required: true },
            weight: { type: Number, required: true },
            imageUrl: { type: String },
            note: { type: String },
            wellbeing: { type: String },
            photos: { type: [String], default: [] },
            biggestWin: { type: String },
            struggles: { type: String },
            questions: { type: String },
        },
    ],
    caloriesLogs: [
        {
            date: { type: Date, required: true },
            calories: { type: Number, required: true },
            note: { type: String },
        },
    ],
    doneWorkouts: {
        type: [
            {
                date: { type: Date, required: true },
                workout: {
                    name: { type: String, required: true },
                    exercises: [
                        {
                            bodyParts: { type: [String], default: [] },
                            exerciseId: { type: String, required: true },
                            minutes: { type: Number, default: 0 },
                            seconds: { type: Number, default: 0 },
                            sets: [
                                {
                                    reps: { type: String, required: true },
                                    rir: { type: Number, required: true },
                                    actualReps: { type: Number, default: null },
                                    weight: { type: Number, required: true },
                                },
                            ],
                            name: { type: String, required: true },
                        },
                    ],
                },
            },
        ],
        default: [],
    },
    type: { type: String, required: true },
    caloriesPerDay: { type: Number },
    lastLogin: { type: Date },
    password: { type: String },
    trainingPlan: {
        lastUpdated: { type: Date },
        name: {
            type: String,
            default: function () {
                return `Plan for ${this.firstName}`;
            },
        },
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
        bodyParts: { type: [String], default: [] },
    },
    hasPassword: { type: Boolean, default: false },
    cancelToken: { type: String },
    // Optional field for storing the cancel token
});
// @ts-ignore
const User = mongoose_1.default.model('User', UserSchema);
exports.default = User;
