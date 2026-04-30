"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const workout_1 = __importDefault(require("../../controllers/mobile/workout"));
const workoutRouter = express_1.default.Router();
workoutRouter.post("/log-workout", workout_1.default.logWorkout.bind(workout_1.default));
exports.default = workoutRouter;
