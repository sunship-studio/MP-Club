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
const stripe_1 = __importDefault(require("../config/stripe"));
const PaymentSession_1 = __importDefault(require("../models/PaymentSession"));
class OnlineCoachingController {
    constructor() {
        // Initialize any properties or dependencies here
    }
    createCheckoutSession(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log(process.env.NODE_ENV);
            const { email, firstName, lastName, age } = req.body;
            try {
                const session = yield stripe_1.default.checkout.sessions.create({
                    payment_method_types: ["card"],
                    mode: "subscription",
                    line_items: [
                        {
                            price: process.env.STRIPE_PRICE_ID,
                            quantity: 1,
                        },
                    ],
                    success_url: process.env.NODE_ENV === "development"
                        ? `http://localhost:3000/online-coaching/success`
                        : `${req.protocol}://${req.get("host")}/online-coaching/success`,
                    cancel_url: process.env.NODE_ENV === "development"
                        ? `http://localhost:3000/online-coaching/`
                        : `${req.protocol}://${req.get("host")}/online-coaching/`,
                });
                console.log("Session created:", session);
                // Store the session ID in your database or perform any other necessary actions
                yield PaymentSession_1.default.create({
                    sessionId: session.id,
                    email,
                    firstName,
                    lastName,
                    age,
                })
                    .then(() => {
                    console.log("Payment session saved to database");
                })
                    .catch((error) => {
                    console.error("Error saving payment session:", error);
                });
                res.status(200).json({
                    sessionId: session.id,
                });
            }
            catch (error) {
                console.error("Error creating subscription:", error);
                res.status(500).json({ error: "Failed to create subscription" });
            }
        });
    }
    handleWebhook(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const sig = req.headers["stripe-signature"];
            const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
            let event;
            try {
                event = stripe_1.default.webhooks.constructEvent(req.body, sig, endpointSecret);
            }
            catch (err) {
                console.error("Error verifying webhook signature:", err);
                return res.status(400).send(`Webhook Error: ${err}`);
            }
            // Handle the event
            switch (event.type) {
                case "checkout.session.completed":
                    const session = event.data.object;
                    console.log("Payment successful:", session);
                    break;
                case "checkout.session.async_payment_failed":
                    console.log("Payment failed:", event.data.object);
                    break;
                default:
                    console.warn(`Unhandled event type: ${event.type}`);
            }
            res.status(200).json({ received: true });
        });
    }
}
exports.default = OnlineCoachingController;
