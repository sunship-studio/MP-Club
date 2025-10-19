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
exports.verifyToken = exports.adminAppAuth = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const User_1 = __importDefault(require("../models/User"));
const adminAppAuth = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const token = req.headers["token"];
    if (token === process.env.ADMIN_TOKEN) {
        next();
    }
    else {
        res.status(401).json({ message: "Unauthorized" });
    }
    return;
});
exports.adminAppAuth = adminAppAuth;
const verifyToken = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    const authHeader = req.headers["authorization"];
    const refreshToken = req.headers["x-refresh-token"];
    if (!authHeader) {
        console.log("No token provided");
        res.status(401).json({ message: "No token provided" });
        return;
    }
    try {
        jsonwebtoken_1.default.verify(authHeader, "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff");
        res.setHeader("authorization", authHeader);
        res.setHeader("x-refresh-token", refreshToken);
        next();
    }
    catch (error) {
        try {
            jsonwebtoken_1.default.verify(refreshToken, "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb");
            const decoded = jsonwebtoken_1.default.decode(refreshToken);
            const newToken = jsonwebtoken_1.default.sign({ id: decoded.id }, "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff", {
                expiresIn: "1h",
            });
            const newRefreshToken = jsonwebtoken_1.default.sign({ id: decoded.id }, "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb", { expiresIn: "7d" });
            res.setHeader("authorization", newToken);
            res.setHeader("x-refresh-token", newRefreshToken);
            const user = yield User_1.default.findById(decoded.id);
            user.token = newToken;
            user.refreshToken = newRefreshToken;
            yield (user === null || user === void 0 ? void 0 : user.save());
            if (!user) {
                console.log('no user found in verifyToken middleware');
                res.status(401).json({ message: "Unauthorized" });
                return;
            }
            next();
        }
        catch (error) {
            console.error("Token verification error:", error);
            res.status(401).json({ message: "Unauthorized" });
            return;
        }
    }
});
exports.verifyToken = verifyToken;
