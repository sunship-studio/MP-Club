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
exports.AuthController = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const auth_1 = require("../../middleware/auth");
const User_1 = __importDefault(require("../../models/User"));
class AuthController {
    static checkEmail(email) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log('Checking email:', email);
            const user = yield User_1.default.findOne({ email: email.replace(/\s+/g, '') });
            console.log('User found:', user);
            const hasPassword = user === null || user === void 0 ? void 0 : user.hasPassword;
            return { exists: user == null ? false : true, hasPassword: hasPassword };
        });
    }
    static hashPassword(password) {
        return __awaiter(this, void 0, void 0, function* () {
            const bcrypt = require('bcrypt');
            const saltRounds = 10;
            const hashedPassword = yield bcrypt.hash(password, saltRounds);
            return hashedPassword;
        });
    }
    static verifyPassword(password, hashedPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            const bcrypt = require('bcrypt');
            return yield bcrypt.compare(password, hashedPassword);
        });
    }
    static forgotPassword(email) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield User_1.default.findOne({
                email,
            });
            if (user) {
            }
        });
    }
    static setPassword(email, newPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            const hashedPassword = yield this.hashPassword(newPassword);
            const user = yield User_1.default.findOneAndUpdate({ email }, { password: hashedPassword, hasPassword: true });
            if (!user) {
                return null;
            }
            const token = jsonwebtoken_1.default.sign({ id: user._id }, auth_1.secret, {
                expiresIn: '1h',
            });
            const refreshToken = jsonwebtoken_1.default.sign({ id: user._id }, auth_1.refreshSecret, {
                expiresIn: '30d',
            });
            user.token = token;
            user.refreshToken = refreshToken;
            yield user.save();
            return { token, refreshToken };
        });
    }
    static login(email, password) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield User_1.default.findOne({ email: email.replace(/\s+/g, '') });
            if (user && user.password) {
                const isMatch = yield this.verifyPassword(password, user.password);
                // create and save jwt tokens
                const token = jsonwebtoken_1.default.sign({ id: user._id }, auth_1.secret, {
                    expiresIn: '10s',
                });
                const refreshToken = jsonwebtoken_1.default.sign({ id: user._id }, auth_1.refreshSecret, {
                    expiresIn: '30d',
                });
                user.token = token;
                user.refreshToken = refreshToken;
                yield user.save();
                if (isMatch) {
                    return { token, refreshToken };
                }
            }
            return null;
        });
    }
    static getUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const token = req.headers['authorization'];
            const refreshToken = req.headers['x-refresh-token'];
            let user = yield User_1.default.findOne({ token: token });
            if (!user) {
                user = yield User_1.default.findOne({ refreshToken: refreshToken });
            }
            if (!user) {
                res.status(401).json({ message: 'Unauthorized' });
            }
            res.json(user);
        });
    }
    static createAccountWithAppleSubscription(userData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { email, firstName, lastName, age, targetWeight, appleReceiptData, subscriptionId, } = userData;
                // Check if user already exists
                const existingUser = yield User_1.default.findOne({
                    email: email.replace(/\s+/g, ''),
                });
                if (existingUser) {
                    return {
                        success: false,
                        message: 'User with this email already exists',
                    };
                }
                // Verify Apple subscription receipt
                const subscriptionValid = yield this.verifyAppleReceipt(appleReceiptData, subscriptionId);
                if (!subscriptionValid.valid) {
                    return {
                        success: false,
                        message: subscriptionValid.message || 'Invalid Apple subscription',
                    };
                }
                // Create new user with Apple subscription
                const newUser = new User_1.default({
                    email: email.replace(/\s+/g, ''),
                    firstName,
                    lastName,
                    age,
                    targetWeight,
                    customerId: `apple_${Date.now()}`, // Generate unique customer ID for Apple users
                    subscriptionId: subscriptionId,
                    status: 'active',
                    type: 'apple_subscription',
                    hasPassword: false,
                    startDate: new Date(),
                });
                // Generate JWT tokens
                const token = jsonwebtoken_1.default.sign({ id: newUser._id }, auth_1.secret, { expiresIn: '1h' });
                const refreshToken = jsonwebtoken_1.default.sign({ id: newUser._id }, auth_1.refreshSecret, {
                    expiresIn: '30d',
                });
                newUser.token = token;
                newUser.refreshToken = refreshToken;
                yield newUser.save();
                return {
                    success: true,
                    message: 'Account created successfully',
                    token,
                    refreshToken,
                    user: newUser,
                };
            }
            catch (error) {
                console.error('Error creating account with Apple subscription:', error);
                return {
                    success: false,
                    message: 'Failed to create account',
                };
            }
        });
    }
    static verifyAppleReceipt(receiptData, subscriptionId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Apple App Store receipt verification
                const isProduction = process.env.NODE_ENV === 'production';
                const verifyURL = isProduction
                    ? 'https://buy.itunes.apple.com/verifyReceipt'
                    : 'https://sandbox.itunes.apple.com/verifyReceipt';
                const requestBody = {
                    'receipt-data': receiptData,
                    password: process.env.APPLE_SHARED_SECRET || '',
                    'exclude-old-transactions': true,
                };
                const response = yield fetch(verifyURL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(requestBody),
                });
                const result = yield response.json();
                // Handle sandbox fallback for production environment
                if (result.status === 21007 && isProduction) {
                    // Receipt is from sandbox, retry with sandbox URL
                    const sandboxResponse = yield fetch('https://sandbox.itunes.apple.com/verifyReceipt', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(requestBody),
                    });
                    const sandboxResult = yield sandboxResponse.json();
                    return this.processAppleReceiptResult(sandboxResult, subscriptionId);
                }
                return this.processAppleReceiptResult(result, subscriptionId);
            }
            catch (error) {
                console.error('Error verifying Apple receipt:', error);
                return {
                    valid: false,
                    message: 'Failed to verify Apple receipt',
                };
            }
        });
    }
    static processAppleReceiptResult(result, subscriptionId) {
        if (result.status !== 0) {
            const statusMessages = {
                21000: 'The App Store could not read the JSON object you provided',
                21002: 'The data in the receipt-data property was malformed or missing',
                21003: 'The receipt could not be authenticated',
                21004: 'The shared secret you provided does not match the shared secret on file',
                21005: 'The receipt server is not currently available',
                21006: 'This receipt is valid but the subscription has expired',
                21007: 'This receipt is from the sandbox environment',
                21008: 'This receipt is from the production environment',
            };
            return {
                valid: false,
                message: statusMessages[result.status] ||
                    `Apple receipt verification failed with status ${result.status}`,
            };
        }
        // Check if receipt contains the expected subscription
        const receipt = result.receipt;
        const latestReceiptInfo = result.latest_receipt_info || [];
        // Look for active subscription matching the provided subscription ID
        const activeSubscription = latestReceiptInfo.find((info) => info.product_id === subscriptionId &&
            new Date(parseInt(info.expires_date_ms)) > new Date());
        if (!activeSubscription) {
            return {
                valid: false,
                message: 'No active subscription found for the provided subscription ID',
            };
        }
        return {
            valid: true,
            message: 'Apple subscription verified successfully',
        };
    }
}
exports.AuthController = AuthController;
exports.default = new AuthController();
