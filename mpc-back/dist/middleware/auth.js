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
exports.verifyTokenInternal = exports.verifyToken = exports.secret = exports.refreshSecret = exports.adminAppAuth = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const User_1 = __importDefault(require("../models/User"));
const refreshSecret = 'b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb';
exports.refreshSecret = refreshSecret;
const secret = 'a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff';
exports.secret = secret;
const adminAppAuth = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const token = req.headers['token'];
    if (token === process.env.ADMIN_TOKEN) {
        next();
    }
    else {
        res.status(401).json({ message: 'Unauthorized' });
    }
    return;
});
exports.adminAppAuth = adminAppAuth;
const verifyToken = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const authHeader = req.headers['authorization'];
    const refreshToken = req.headers['x-refresh-token'];
    if (!authHeader) {
        console.log('No token provided');
        res.status(401).json({ message: 'No token provided' });
        return;
    }
    try {
        const decoded = jsonwebtoken_1.default.verify(authHeader, secret);
        // Attach user to request
        req.user = { id: decoded.id };
        next();
    }
    catch (error) {
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            try {
                jsonwebtoken_1.default.verify(refreshToken, refreshSecret);
                const decoded = jsonwebtoken_1.default.decode(refreshToken);
                const newToken = jsonwebtoken_1.default.sign({ id: decoded.id }, secret, {
                    expiresIn: '10s',
                });
                res.setHeader('authorization', newToken);
                const user = yield User_1.default.findById(decoded.id);
                user.token = newToken;
                yield (user === null || user === void 0 ? void 0 : user.save());
                if (!user) {
                    console.log('no user found in verifyToken middleware');
                    res.status(401).json({ message: 'Unauthorized' });
                    return;
                }
                // Attach user to request
                req.user = { id: decoded.id };
                next();
            }
            catch (error) {
                console.error('Token verification error:', error);
                res.status(401).json({ message: 'Unauthorized' });
                return;
            }
        }
    }
});
exports.verifyToken = verifyToken;
const verifyTokenInternal = (token, refreshToken) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        jsonwebtoken_1.default.verify(token, secret);
        return jsonwebtoken_1.default.decode(token);
    }
    catch (error) {
        try {
            jsonwebtoken_1.default.verify(refreshToken, refreshSecret);
            const decoded = jsonwebtoken_1.default.decode(refreshToken);
            const newToken = jsonwebtoken_1.default.sign({ id: decoded.id }, secret, {
                expiresIn: '10s',
            });
            const user = yield User_1.default.findById(decoded.id);
            user.token = newToken;
            yield (user === null || user === void 0 ? void 0 : user.save());
            if (!user) {
                console.log('no user found in verifyToken middleware');
                return null;
            }
            return jsonwebtoken_1.default.decode(newToken);
        }
        catch (error) {
            console.error('Token verification error:', error);
            return null;
        }
    }
});
exports.verifyTokenInternal = verifyTokenInternal;
