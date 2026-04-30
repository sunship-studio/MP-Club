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
const User_1 = __importDefault(require("../../models/User"));
function toNumberOrNull(v) {
    if (v === null || v === undefined || v === "")
        return null;
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isFinite(n))
        return null;
    if (n < 0)
        return null;
    return n;
}
function toIntOrZero(v) {
    const n = toNumberOrNull(v);
    return n === null ? 0 : Math.round(n);
}
function sanitizeSet(raw) {
    return {
        reps: raw.reps == null ? "0" : String(raw.reps),
        rir: toIntOrZero(raw.rir),
        weight: toIntOrZero(raw.weight),
        actualReps: toNumberOrNull(raw.actualReps),
    };
}
function sanitizeExercise(raw) {
    const sets = Array.isArray(raw.sets)
        ? raw.sets.map((s) => sanitizeSet(s))
        : [];
    const bodyParts = Array.isArray(raw.bodyParts)
        ? raw.bodyParts.map((b) => String(b))
        : [];
    return {
        exerciseId: raw.exerciseId ? String(raw.exerciseId) : "",
        name: raw.name ? String(raw.name) : "",
        videoUrl: raw.videoUrl ? String(raw.videoUrl) : undefined,
        bodyParts,
        minutes: toIntOrZero(raw.minutes),
        seconds: toIntOrZero(raw.seconds),
        sets,
    };
}
function sanitizeWorkoutEntry(raw) {
    var _a;
    let date;
    if (raw.date) {
        const parsed = new Date(raw.date);
        date = isNaN(parsed.getTime()) ? new Date() : parsed;
    }
    else {
        date = new Date();
    }
    const inner = (_a = raw.workout) !== null && _a !== void 0 ? _a : {};
    const exercises = Array.isArray(inner.exercises)
        ? inner.exercises.map((e) => sanitizeExercise(e))
        : [];
    return {
        date,
        workout: {
            name: inner.name ? String(inner.name) : "",
            exercises,
        },
    };
}
class WorkoutController {
    logWorkout(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            const { userId, workout } = (_a = req.body) !== null && _a !== void 0 ? _a : {};
            if (!userId || typeof userId !== "string") {
                res.status(400).json({ success: false, error: "userId is required" });
                return;
            }
            if (!workout || typeof workout !== "object") {
                res.status(400).json({ success: false, error: "workout is required" });
                return;
            }
            try {
                const user = yield User_1.default.findById(userId);
                if (!user) {
                    res.status(404).json({ success: false, error: "User not found" });
                    return;
                }
                const entry = sanitizeWorkoutEntry(workout);
                if (!entry.workout.name || entry.workout.exercises.length === 0) {
                    res.status(400).json({
                        success: false,
                        error: "workout must have a name and at least one exercise",
                    });
                    return;
                }
                user.doneWorkouts.push(entry);
                yield user.save();
                const saved = user.doneWorkouts[user.doneWorkouts.length - 1];
                res.status(200).json({ success: true, entry: saved });
            }
            catch (error) {
                console.error("Error logging workout:", error);
                res.status(500).json({ success: false, error: "Server error" });
            }
        });
    }
}
exports.default = new WorkoutController();
