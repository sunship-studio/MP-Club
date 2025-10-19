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
const User_1 = __importDefault(require("../../models/User"));
class AuthController {
    static checkEmail(email) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log("Checking email:", email);
            const user = yield User_1.default.findOne({ email: email.replace(/\s+/g, "") });
            console.log("User found:", user);
            const hasPassword = user === null || user === void 0 ? void 0 : user.hasPassword;
            return { exists: user == null ? false : true, hasPassword: hasPassword };
        });
    }
    static hashPassword(password) {
        return __awaiter(this, void 0, void 0, function* () {
            const bcrypt = require("bcrypt");
            const saltRounds = 10;
            const hashedPassword = yield bcrypt.hash(password, saltRounds);
            return hashedPassword;
        });
    }
    static verifyPassword(password, hashedPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            const bcrypt = require("bcrypt");
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
            const token = jsonwebtoken_1.default.sign({ id: user._id }, "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff", {
                expiresIn: "1h",
            });
            const refreshToken = jsonwebtoken_1.default.sign({ id: user._id }, "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb", { expiresIn: "7d" });
            user.token = token;
            user.refreshToken = refreshToken;
            yield user.save();
            return { token, refreshToken };
        });
    }
    static login(email, password) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield User_1.default.findOne({ email: email.replace(/\s+/g, "") });
            if (user && user.password) {
                const isMatch = yield this.verifyPassword(password, user.password);
                // create and save jwt tokens
                const token = jsonwebtoken_1.default.sign({ id: user._id }, "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff", {
                    expiresIn: "10s",
                });
                const refreshToken = jsonwebtoken_1.default.sign({ id: user._id }, "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb", { expiresIn: "7d" });
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
    static getUser(token) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield User_1.default.findOne({ token: token });
            console.log("User found in getUser:", user);
            return user;
        });
    }
}
exports.AuthController = AuthController;
exports.default = new AuthController();
