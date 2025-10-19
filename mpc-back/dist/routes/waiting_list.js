"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const waiting_list_1 = __importDefault(require("../controllers/web/waiting_list"));
// Waiting List Router
const waitingListRouter = express_1.default.Router();
const waitingListController = new waiting_list_1.default();
// Add a new user to the waiting list
waitingListRouter.post('/add', waitingListController.addUserToWaitingList);
exports.default = waitingListRouter;
