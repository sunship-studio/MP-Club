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
const mobile_app_1 = __importDefault(require("../controllers/mobile_app"));
const auth_1 = __importDefault(require("../middleware/auth"));
// Mobile App Router
const mobileAppRouter = express_1.default.Router();
const mobileAppController = new mobile_app_1.default();
// Route to get the waiting list
mobileAppRouter.get("/waiting-list", auth_1.default, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield mobileAppController.getWaitingList(req, res);
}));
// Route to get online subscriptions
mobileAppRouter.get("/online-subscriptions", auth_1.default, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield mobileAppController.getOnlineSubscriptions(req, res);
}));
mobileAppRouter.post('/waiting-list/reject', auth_1.default, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield mobileAppController.rejectWaitingList(req, res);
}));
mobileAppRouter.post('/waiting-list/accept', auth_1.default, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield mobileAppController.acceptWaitingList(req, res);
}));
exports.default = mobileAppRouter;
