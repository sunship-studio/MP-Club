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
exports.CheckInController = void 0;
const User_1 = __importDefault(require("../../models/User"));
const notification_1 = require("../../services/notification");
class CheckInController {
    static checkIn(_a) {
        return __awaiter(this, arguments, void 0, function* ({ userId, weight, imageUrl, note, wellbeing, photos, biggestWin, struggles, questions, }) {
            const user = yield User_1.default.findById(userId);
            if (!user) {
                return false;
            }
            console.log('data', {
                userId,
                weight,
                imageUrl,
                note,
                wellbeing,
                photos,
                biggestWin,
                struggles,
                questions,
            });
            user.checkIns.push({
                date: new Date(),
                weight,
                imageUrl,
                note,
                wellbeing,
                photos: photos || [],
                biggestWin,
                struggles,
                questions,
            });
            yield user.save();
            // Send notification to Shane about the check-in
            const userName = `${user.firstName} ${user.lastName}`;
            const weightInfo = `Weight: ${weight} lbs`;
            const noteInfo = note ? ` - Note: ${note}` : '';
            yield (0, notification_1.sendNotificationToAdmin)(`${userName} checked in! ${weightInfo}${noteInfo}`, 'New Check-In', {
                type: 'check-in',
                userId: user._id.toString(),
            });
            return true;
        });
    }
    static editCheckIn(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId, weight, note } = req.body;
            const checkInId = req.params.id;
            try {
                const user = yield User_1.default.findById(userId);
                if (!user) {
                    res.status(404).json({ success: false, error: 'User not found' });
                    return false;
                }
                const checkIn = user.checkIns.find((ci) => ci._id.toString() === checkInId);
                if (!checkIn) {
                    res.status(404).json({ success: false, error: 'Check-in not found' });
                    return false;
                }
                checkIn.weight = weight;
                if (note) {
                    checkIn.note = note;
                }
                yield user.save();
                res.status(200).json({ success: true });
                return true;
            }
            catch (error) {
                res.status(500).json({ success: false, error: 'Error editing check-in' });
                console.error('Error editing check-in:', error);
                return false;
            }
        });
    }
}
exports.CheckInController = CheckInController;
