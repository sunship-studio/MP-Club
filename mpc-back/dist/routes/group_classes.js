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
exports.groupClassController = void 0;
const express_1 = require("express");
const group_class_controller_1 = __importDefault(require("../controllers/web/group_class_controller"));
const groupClassRouter = (0, express_1.Router)();
const groupClassController = new group_class_controller_1.default();
exports.groupClassController = groupClassController;
groupClassRouter.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.getGroupClasses(req, res);
}));
groupClassRouter.get('/passes', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.getPassProducts(req, res);
}));
groupClassRouter.get('/passes/mine', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.getMyPass(req, res);
}));
groupClassRouter.post('/passes/create-checkout-session', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.createPassCheckoutSession(req, res);
}));
groupClassRouter.get('/my-bookings', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.getMyBookings(req, res);
}));
groupClassRouter.post('/passes/auto-renew', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.setAutoRenew(req, res);
}));
groupClassRouter.post('/book-with-pass', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.bookWithPass(req, res);
}));
groupClassRouter.post('/cancel-with-pass', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.cancelPassBooking(req, res);
}));
groupClassRouter.post('/create-checkout-session', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.createCheckoutSession(req, res);
}));
exports.default = groupClassRouter;
