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
const WaitingListEntry_1 = require("../models/WaitingListEntry");
const stripe_1 = __importDefault(require("../config/stripe"));
class MobileAppController {
    getWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const waitingList = yield WaitingListEntry_1.WaitingListEntry.find();
                if (!waitingList || waitingList.length === 0) {
                    return res.status(404).json({ message: "No entries found" });
                }
                // Sort the waiting list by createdAt in descending order
                waitingList.sort((a, b) => {
                    return b.dateApplied.getTime() - a.dateApplied.getTime();
                });
                return res.status(200).json(waitingList);
            }
            catch (error) {
                console.error("Error fetching waiting list:", error);
                return res.status(500).json({ message: "Internal server error" });
            }
        });
    }
    getOnlineSubscriptions(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscriptions = yield stripe_1.default.subscriptions.list({
                    expand: ["data.customer"],
                    price: process.env.STRIPE_PRICE_ID,
                });
                if (!subscriptions || subscriptions.data.length === 0) {
                    return res.status(404).json({ message: "No subscriptions found" });
                }
                // Sort the subscriptions by createdAt in descending order
                subscriptions.data.sort((a, b) => {
                    return b.created - a.created;
                });
                return res.status(200).json(subscriptions.data
                    .map((sub) => {
                    if (typeof sub.customer !== "string" &&
                        sub.customer &&
                        !sub.customer.deleted) {
                        return {
                            customerId: sub.customer.id,
                            email: sub.customer.email || "No email",
                            subscriptionId: sub.id,
                            startDate: sub.start_date,
                            status: sub.status,
                        };
                    }
                    return null;
                })
                    .filter(Boolean));
            }
            catch (error) {
                console.error("Error fetching online subscriptions:", error);
                return res.status(500).json({ message: "Internal server error" });
            }
        });
    }
    rejectWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const entry = yield WaitingListEntry_1.WaitingListEntry.findById(id);
                if (!entry) {
                    return res.status(404).json({ message: "Entry not found" });
                }
                entry.approvalStatus = "rejected";
                yield entry.save();
                return res.status(200).json({ message: "Entry rejected" });
            }
            catch (error) {
                console.error("Error rejecting waiting list entry:", error);
                return res.status(500).json({ message: "Internal server error" });
            }
        });
    }
    acceptWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const entry = yield WaitingListEntry_1.WaitingListEntry.findById(id);
                if (!entry) {
                    return res.status(404).json({ message: "Entry not found" });
                }
                entry.approvalStatus = "approved";
                entry.approvedDate = new Date();
                yield entry.save();
                return res.status(200).json({ message: "Entry approved" });
            }
            catch (error) {
                console.error("Error approving waiting list entry:", error);
                return res.status(500).json({ message: "Internal server error" });
            }
        });
    }
}
exports.default = MobileAppController;
