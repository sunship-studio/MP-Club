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
exports.getAdminFCMToken = getAdminFCMToken;
exports.getUserFCMToken = getUserFCMToken;
exports.removeAdminFCMToken = removeAdminFCMToken;
exports.removeUserFCMToken = removeUserFCMToken;
exports.sendChatNotification = sendChatNotification;
exports.sendChatNotificationToAdmin = sendChatNotificationToAdmin;
exports.sendCheckInReminder = sendCheckInReminder;
exports.sendNotificationToAdmin = sendNotificationToAdmin;
exports.sendNotificationToDebug = sendNotificationToDebug;
exports.sendNotificationToMultipleUsers = sendNotificationToMultipleUsers;
exports.sendNotificationToUser = sendNotificationToUser;
exports.sendWorkoutPlanNotification = sendWorkoutPlanNotification;
exports.storeAdminFCMToken = storeAdminFCMToken;
exports.storeUserFCMToken = storeUserFCMToken;
const admin_1 = __importDefault(require("../config/admin"));
const AdminSettings_1 = __importDefault(require("../models/AdminSettings"));
const User_1 = __importDefault(require("../models/User"));
// ========================================
// ADMIN FCM TOKEN MANAGEMENT
// ========================================
/**
 * Store or update FCM token for Shane (admin)
 * @param token - FCM token from Shane's device
 * @param debug - Optional flag to store in debug token
 */
function storeAdminFCMToken(token_1) {
    return __awaiter(this, arguments, void 0, function* (token, debug = false) {
        try {
            if (debug) {
                yield AdminSettings_1.default.findOneAndUpdate({ key: 'debug_fcm_token' }, { value: token }, { upsert: true, new: true });
                console.log('✅ Debug FCM token stored for admin');
            }
            // Upsert the token (update if exists, insert if doesn't)
            yield AdminSettings_1.default.findOneAndUpdate({ key: 'admin_fcm_token' }, { value: token }, { upsert: true, new: true });
            console.log('✅ FCM token stored for admin (Shane)');
            return true;
        }
        catch (error) {
            console.error('Error storing admin FCM token:', error);
            throw error;
        }
    });
}
/**
 * Get FCM token for Shane (admin)
 */
function getAdminFCMToken() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const setting = yield AdminSettings_1.default.findOne({ key: 'admin_fcm_token' });
            return setting ? setting.value : null;
        }
        catch (error) {
            console.error('Error retrieving admin FCM token:', error);
            throw error;
        }
    });
}
/**
 * Remove admin FCM token (on Shane's logout)
 */
function removeAdminFCMToken() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield AdminSettings_1.default.findOneAndDelete({ key: 'admin_fcm_token' });
            console.log('🗑️ FCM token removed for admin (Shane)');
            return true;
        }
        catch (error) {
            console.error('Error removing admin FCM token:', error);
            throw error;
        }
    });
}
/**
 * Send push notification to Shane (admin)
 * @param title - Notification title
 * @param body - Notification body
 * @param data - Optional additional data
 */
function sendNotificationToAdmin(title, body, data) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const adminFCMToken = yield getAdminFCMToken();
            if (!adminFCMToken) {
                console.log('⚠️ No FCM token found for admin (Shane)');
                return false;
            }
            yield admin_1.default.messaging().send({
                token: adminFCMToken,
                notification: {
                    title: title,
                    body: body,
                },
                data: Object.assign({ title: title, body: body }, data),
                apns: {
                    headers: {
                        'apns-priority': '10',
                    },
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'admin_notifications',
                    },
                },
            });
            console.log(`📤 Notification sent to admin (Shane): ${title} - ${body}`);
            return true;
        }
        catch (error) {
            // Handle invalid token errors
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                console.log('🗑️ Invalid admin token, removing...');
                yield removeAdminFCMToken();
            }
            else if (error.code === 'messaging/third-party-auth-error') {
                console.error('⚠️ APNs/FCM Auth Error for admin (Shane):');
                console.error('   → This is likely an APNs certificate/key issue in Firebase Console');
                console.error('   → Check: Firebase Console → Project Settings → Cloud Messaging');
                console.error('   → Ensure APNs Authentication Key is uploaded for iOS');
                console.error('   → For production iOS apps, upload APNs Auth Key (.p8 file)');
            }
            else {
                console.error('❌ Error sending notification to admin:', error.code || error.message);
            }
            return false;
        }
    });
}
/**
 * Send notification to debug token (for testing)
 * @param title - Notification title
 * @param body - Notification body
 */
function sendNotificationToDebug(title, body, data) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const debugFCMToken = yield AdminSettings_1.default.findOne({
                key: 'debug_fcm_token',
            });
            if (!(debugFCMToken === null || debugFCMToken === void 0 ? void 0 : debugFCMToken.value)) {
                console.log('⚠️ No debug FCM token found');
                return false;
            }
            yield admin_1.default.messaging().send({
                token: debugFCMToken.value,
                notification: {
                    title: title,
                    body: body,
                },
                data: Object.assign({ title: title, body: body }, data),
                apns: {
                    headers: {
                        'apns-priority': '10',
                    },
                    payload: {
                        aps: {
                            sound: 'default',
                        },
                    },
                },
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                    },
                },
            });
            console.log(`📤 Debug notification sent: ${title}`);
            return true;
        }
        catch (error) {
            console.error('Error sending debug notification:', error);
            return false;
        }
    });
}
// ========================================
// USER FCM TOKEN MANAGEMENT
// ========================================
/**
 * Store or update FCM token for a specific user
 * @param userId - User's MongoDB ObjectId
 * @param token - FCM token from the device
 */
function storeUserFCMToken(userId, token) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield User_1.default.findByIdAndUpdate(userId, { fcmToken: token }, { new: true });
            console.log(`✅ FCM token stored for user ${userId}`);
            return true;
        }
        catch (error) {
            console.error('Error storing user FCM token:', error);
            throw error;
        }
    });
}
/**
 * Get FCM token for a specific user
 * @param userId - User's MongoDB ObjectId
 */
function getUserFCMToken(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield User_1.default.findById(userId).select('fcmToken');
            return (user === null || user === void 0 ? void 0 : user.fcmToken) || null;
        }
        catch (error) {
            console.error('Error retrieving user FCM token:', error);
            throw error;
        }
    });
}
/**
 * Remove FCM token for a user (e.g., on logout)
 * @param userId - User's MongoDB ObjectId
 */
function removeUserFCMToken(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield User_1.default.findByIdAndUpdate(userId, { $unset: { fcmToken: '' } }, { new: true });
            console.log(`🗑️ FCM token removed for user ${userId}`);
            return true;
        }
        catch (error) {
            console.error('Error removing user FCM token:', error);
            throw error;
        }
    });
}
/**
 * Send push notification to a specific user
 * @param userId - User's MongoDB ObjectId
 * @param payload - Notification content
 */
function sendNotificationToUser(userId, payload) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const userFCMToken = yield getUserFCMToken(userId);
            if (!userFCMToken) {
                console.log(`⚠️ No FCM token found for user ${userId}`);
                return false;
            }
            const message = {
                token: userFCMToken,
                notification: {
                    title: payload.title,
                    body: payload.body,
                },
                data: Object.assign({ title: payload.title, body: payload.body }, payload.data),
                apns: {
                    headers: {
                        'apns-priority': '10',
                    },
                    payload: {
                        aps: {
                            sound: 'default',
                            badge: 1,
                        },
                    },
                },
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'chat_messages',
                    },
                },
            };
            if (payload.imageUrl) {
                message.notification.imageUrl = payload.imageUrl;
            }
            yield admin_1.default.messaging().send(message);
            console.log(`📤 Notification sent to user ${userId}: ${payload.title}`);
            return true;
        }
        catch (error) {
            // Handle invalid token errors
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                console.log(`🗑️ Invalid token for user ${userId}, removing...`);
                yield removeUserFCMToken(userId);
            }
            else if (error.code === 'messaging/third-party-auth-error') {
                console.error(`⚠️ APNs/FCM Auth Error for user ${userId}:`);
                console.error('   → This is likely an APNs certificate/key issue in Firebdase Console');
                console.error('   → Check: Firebase Console → Project Settings → Cloud Messaging → APNs Certificates');
                console.error('   → For iOS: Ensure APNs Authentication Key or Certificate is uploaded');
                console.error('   → For Android: This error is rare, check FCM server key');
            }
            else {
                console.error(`❌ Error sending notification to user ${userId}:`, error.code || error.message);
            }
            return false;
        }
    });
}
/**
 * Send push notification to multiple users
 * @param userIds - Array of user MongoDB ObjectIds
 * @param payload - Notification content
 */
function sendNotificationToMultipleUsers(userIds, payload) {
    return __awaiter(this, void 0, void 0, function* () {
        const results = yield Promise.allSettled(userIds.map((userId) => sendNotificationToUser(userId, payload)));
        const success = results.filter((r) => r.status === 'fulfilled' && r.value).length;
        const failed = results.length - success;
        console.log(`📊 Bulk notification results: ${success} success, ${failed} failed`);
        return { success, failed };
    });
}
/**
 * Send notification about new chat message
 */
function sendChatNotification(userId, senderName, messagePreview, chatRoomId) {
    return __awaiter(this, void 0, void 0, function* () {
        return sendNotificationToUser(userId, {
            title: `New message from ${senderName}`,
            body: messagePreview,
            data: {
                type: 'chat_message',
                chatRoomId,
                senderId: senderName,
            },
        });
    });
}
/**
 * Send notification to Shane about new client message
 */
function sendChatNotificationToAdmin(clientName, messagePreview, clientId) {
    return __awaiter(this, void 0, void 0, function* () {
        return sendNotificationToAdmin(`New message from ${clientName}`, messagePreview, {
            type: 'chat_message',
            chatRoomId: clientId,
            senderId: clientId,
        });
    });
}
/**
 * Send notification about workout plan update
 */
function sendWorkoutPlanNotification(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        return sendNotificationToUser(userId, {
            title: 'Training Plan Updated',
            body: 'Shane has updated your training plan. Check it out!',
            data: {
                type: 'workout_plan_update',
            },
        });
    });
}
/**
 * Send notification about check-in reminder
 */
function sendCheckInReminder(userId) {
    return __awaiter(this, void 0, void 0, function* () {
        return sendNotificationToUser(userId, {
            title: 'Time for your Check-in',
            body: "Don't forget to log your progress today!",
            data: {
                type: 'check_in_reminder',
            },
        });
    });
}
