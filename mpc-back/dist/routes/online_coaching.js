"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const online_coaching_1 = __importDefault(require("../controllers/online_coaching"));
// Online Coaching Router
const onlineCoachingRouter = express_1.default.Router();
const onlineCoachingController = new online_coaching_1.default();
// Create Subscription
onlineCoachingRouter.post("/create-checkout-session", onlineCoachingController.createCheckoutSession);
// webhook for Stripe
onlineCoachingRouter.post("/webhook", express_1.default.raw({ type: "application/json" }));
exports.default = onlineCoachingRouter;
