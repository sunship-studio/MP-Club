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
const admin_app_1 = __importDefault(require("../controllers/admin/admin_app"));
const auth_1 = require("../middleware/auth");
// Mobile App Router
const adminAppRouter = express_1.default.Router();
const adminAppController = new admin_app_1.default();
// Route to get the waiting list
adminAppRouter.get('/waiting-list', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield adminAppController.getWaitingList(req, res);
}));
adminAppRouter.get('/exercises', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield adminAppController.getAllExercises(req, res);
}));
// Route to get online subscriptions
adminAppRouter.get('/online-users', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield adminAppController.getOnlineCoachingUsers(req, res);
}));
adminAppRouter.post('/waiting-list/reject', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield adminAppController.rejectWaitingList(req, res);
}));
adminAppRouter.post('/waiting-list/accept', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield adminAppController.acceptWaitingList(req, res);
}));
adminAppRouter.post('/user-calories', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Received request to save user calories:', req.body);
    yield adminAppController.saveUserCalories(req, res);
}));
adminAppRouter.post('/user-target-weight', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Received request to save user target weight:', req.body);
    yield adminAppController.saveUserTargetWeight(req, res);
}));
adminAppRouter.post('/save-training-plan', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Received request to save training plan:', req.body);
    yield adminAppController.saveTrainingPlan(req, res);
}));
adminAppRouter.post('/add-subscriber', auth_1.adminAppAuth, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Received request to add subscriber:', req.body);
    yield adminAppController.addSubscriber(req, res);
}));
exports.default = adminAppRouter;
