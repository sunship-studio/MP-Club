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
Object.defineProperty(exports, "__esModule", { value: true });
const WaitingListEntry_1 = require("../../models/WaitingListEntry");
const notification_1 = require("../../services/notification");
class WaitingListController {
    // Add a new user to the waiting list
    addUserToWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { firstName, lastName, email, age, availableWeekdays } = req.body;
                const newEntry = new WaitingListEntry_1.WaitingListEntry({
                    firstName,
                    lastName,
                    email,
                    age,
                });
                // Set weekly availability from the request body
                availableWeekdays.forEach((day) => {
                    const dayName = day.name.toLowerCase();
                    if (newEntry.weeklyAvailability &&
                        dayName in newEntry.weeklyAvailability) {
                        newEntry.weeklyAvailability[dayName] = {
                            available: true,
                            startTime: day.startTime,
                            allDay: day.allDay,
                            endTime: day.endTime,
                        };
                    }
                });
                yield newEntry.save();
                res
                    .status(201)
                    .json({ message: "User added to waiting list", entry: newEntry });
                (0, notification_1.sendNotificationToAdmin)(`New user added to waiting list: ${firstName} ${lastName}`, "New Waiting List Entry");
            }
            catch (error) {
                console.error("Error adding user to waiting list:", error);
                res
                    .status(500)
                    .json({ message: "Error adding user to waiting list", error });
            }
        });
    }
}
exports.default = WaitingListController;
