"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const online_coaching_1 = __importDefault(require("../controllers/web/online_coaching"));
const body_parser_1 = __importDefault(require("body-parser"));
// Online Coaching Router
const onlineCoachingRouter = express_1.default.Router();
const onlineCoachingController = new online_coaching_1.default();
// Create Subscription
onlineCoachingRouter.post("/create-checkout-session", body_parser_1.default.json(), onlineCoachingController.createCheckoutSession);
onlineCoachingRouter.post("/cancel", onlineCoachingController.cancelSubscription);
onlineCoachingRouter.post("/confirm_cancel", body_parser_1.default.json(), onlineCoachingController.confirmCancelSubscription);
exports.default = onlineCoachingRouter;
