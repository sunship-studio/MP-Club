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
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const notification_1 = require("../services/notification");
const notificationsRouter = express_1.default.Router();
// ========================================
// ADMIN (SHANE) ENDPOINTS
// ========================================
// Admin FCM token registration
notificationsRouter.post('/save_token', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { token, debug } = req.body;
        if (!token) {
            res.status(400).json({ error: 'Token is required' });
            return;
        }
        yield (0, notification_1.storeAdminFCMToken)(token, debug || false);
        res.status(200).json({
            message: 'Admin token stored successfully',
            success: true,
        });
    }
    catch (error) {
        console.error('Error storing admin FCM token:', error);
        res.status(500).json({
            error: 'Failed to store admin token',
            message: error.message,
        });
    }
}));
// Admin FCM token removal (on Shane's logout)
notificationsRouter.post('/remove_admin_token', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        yield (0, notification_1.removeAdminFCMToken)();
        res.status(200).json({
            message: 'Admin token removed successfully',
            success: true,
        });
    }
    catch (error) {
        console.error('Error removing admin FCM token:', error);
        res.status(500).json({
            error: 'Failed to remove admin token',
            message: error.message,
        });
    }
}));
// ========================================
// USER (CLIENT) ENDPOINTS
// ========================================
// User FCM token registration (protected route)
notificationsRouter.post('/register-token', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { fcmToken } = req.body;
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
        if (!userId) {
            res.status(401).json({ error: 'User not authenticated' });
            return;
        }
        if (!fcmToken) {
            res.status(400).json({ error: 'FCM token is required' });
            return;
        }
        yield (0, notification_1.storeUserFCMToken)(userId, fcmToken);
        res.status(200).json({
            message: 'FCM token registered successfully',
            success: true,
        });
    }
    catch (error) {
        console.error('Error registering FCM token:', error);
        res.status(500).json({
            error: 'Failed to register FCM token',
            message: error.message,
        });
    }
}));
// Remove user FCM token (on logout)
notificationsRouter.post('/remove-token', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
        if (!userId) {
            res.status(401).json({ error: 'User not authenticated' });
            return;
        }
        yield (0, notification_1.removeUserFCMToken)(userId);
        res.status(200).json({
            message: 'FCM token removed successfully',
            success: true,
        });
    }
    catch (error) {
        console.error('Error removing FCM token:', error);
        res.status(500).json({
            error: 'Failed to remove FCM token',
            message: error.message,
        });
    }
}));
exports.default = notificationsRouter;
