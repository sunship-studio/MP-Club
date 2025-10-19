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
class WorkoutController {
    logWorkout(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId, workout } = req.body;
            try {
                const user = yield User_1.default.findById(userId);
                if (!user) {
                    console.error("User not found");
                    return false;
                }
                console.log("Workout to be logged:", workout);
                user.doneWorkouts.push(workout);
                yield user.save();
                res.status(200).json({ success: true });
            }
            catch (error) {
                console.error("Error logging workout:", error);
                res.status(500).json({ success: false });
            }
        });
    }
}
module.exports = new WorkoutController();
