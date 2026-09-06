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
const express_1 = require("express");
const auth_1 = __importDefault(require("../controllers/web/auth"));
const customerAuthRouter = (0, express_1.Router)();
const authController = new auth_1.default();
customerAuthRouter.post('/request-link', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield authController.requestSignInLink(req, res);
}));
customerAuthRouter.post('/verify', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield authController.verifySignInLink(req, res);
}));
customerAuthRouter.get('/me', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield authController.getCurrentCustomer(req, res);
}));
customerAuthRouter.post('/sign-out', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield authController.signOut(req, res);
}));
exports.default = customerAuthRouter;
