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
const auth_1 = require("../../controllers/mobile/auth");
const authRouter = express_1.default.Router();
authRouter.post("/check-email", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log("Request body:", req.body);
        const { email } = req.body;
        const data = yield auth_1.AuthController.checkEmail(email);
        console.log("Email check data:", data);
        res.json({ exists: data.exists, hasPassword: data.hasPassword });
    }
    catch (error) {
        res.status(500).json({ message: "Error checking email" });
    }
}));
authRouter.post("/set-password", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, newPassword } = req.body;
    const result = yield auth_1.AuthController.setPassword(email, newPassword);
    res.setHeader("authorization", (result === null || result === void 0 ? void 0 : result.token) || "");
    res.setHeader("x-refresh-token", (result === null || result === void 0 ? void 0 : result.refreshToken) || "");
    res.json({
        message: "Password set successfully",
    });
}));
authRouter.post("/login", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, password } = req.body;
    const tokens = yield auth_1.AuthController.login(email, password);
    res.setHeader("authorization", (tokens === null || tokens === void 0 ? void 0 : tokens.token) || "");
    res.setHeader("x-refresh-token", (tokens === null || tokens === void 0 ? void 0 : tokens.refreshToken) || "");
    if (tokens) {
        res.json({
            message: "Login successful",
        });
    }
    else {
        res.status(401).json({ message: "Invalid email or password" });
    }
}));
authRouter.post("/forgot-password", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email } = req.body;
}));
authRouter.get("/user", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log("Getting user with token:", req.headers["authorization"]);
    const user = yield auth_1.AuthController.getUser(req.headers["authorization"]);
    res.json(user);
}));
exports.default = authRouter;
