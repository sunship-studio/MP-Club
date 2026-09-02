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
groupClassRouter.post('/create-checkout-session', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield groupClassController.createCheckoutSession(req, res);
}));
exports.default = groupClassRouter;
