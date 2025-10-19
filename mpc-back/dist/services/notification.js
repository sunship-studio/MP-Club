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
exports.storeAdminFCMToken = storeAdminFCMToken;
exports.getAdminFCMToken = getAdminFCMToken;
exports.sendNotificationToAdmin = sendNotificationToAdmin;
exports.sendNotificationToDebug = sendNotificationToDebug;
const admin_1 = __importDefault(require("../config/admin"));
const AdminSettings_1 = __importDefault(require("../models/AdminSettings"));
// Storing or updating the FCM token
function storeAdminFCMToken(token, debug) {
    return __awaiter(this, void 0, void 0, function* () {
        if (debug) {
            yield AdminSettings_1.default.findOneAndUpdate({ key: "debug_fcm_token" }, { value: token }, { upsert: true, new: true });
        }
        try {
            // Upsert the token (update if exists, insert if doesn't)
            yield AdminSettings_1.default.findOneAndUpdate({ key: "admin_fcm_token" }, { value: token }, { upsert: true, new: true });
            return true;
        }
        catch (error) {
            console.error("Error storing admin FCM token:", error);
            throw error;
        }
    });
}
// Retrieving the token when needed
function getAdminFCMToken() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const setting = yield AdminSettings_1.default.findOne({ key: "admin_fcm_token" });
            return setting ? setting.value : null;
        }
        catch (error) {
            console.error("Error retrieving admin FCM token:", error);
            throw error;
        }
    });
}
function sendNotificationToAdmin(title, body) {
    return __awaiter(this, void 0, void 0, function* () {
        const adminFCMToken = yield getAdminFCMToken();
        if (adminFCMToken) {
            admin_1.default.messaging().send({
                token: adminFCMToken,
                notification: {
                    title: title,
                    body: body,
                },
                data: {
                    title: title,
                    body: body,
                },
            });
            console.log(`Sending notification to admin: ${title} - ${body}`);
        }
        else {
            console.error("No FCM token found for admin.");
        }
    });
}
function sendNotificationToDebug(title, body) {
    return __awaiter(this, void 0, void 0, function* () {
        const debugFCMToken = "fozeAy38bk6LgLmLDuqt-I:APA91bEsA56_HAN2FZNuvvMrStvlFtt5Raq-bfFbxnavya01OXPRRm2UUFUchA1xBOlSsz0XYCwnFVwbeh6dW_jndgHFi8vdYvIdfcog7Jcai7kcaTelQkA";
        admin_1.default.messaging().send({
            token: debugFCMToken,
            notification: {
                title: title,
                body: body,
            },
            data: {
                title: title,
                body: body,
            },
            apns: {
                headers: {
                    'apns-priority': '10'
                },
                payload: {
                    aps: {
                        sound: 'default'
                    }
                }
            }
        });
    });
}
