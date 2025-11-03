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
exports.handleWebhook = void 0;
const mail_1 = __importDefault(require("@sendgrid/mail"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const stripe_1 = __importDefault(require("stripe"));
const PaymentSession_1 = __importDefault(require("../models/PaymentSession"));
const User_1 = __importDefault(require("../models/User"));
const notification_1 = require("../services/notification");
mail_1.default.setApiKey(process.env.SENDGRID_API_KEY);
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY, {});
const handleWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const sig = req.headers["stripe-signature"];
    const endpointSecret = process.env.NODE_ENV == "development"
        ? "whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47"
        : process.env.STRIPE_WEBHOOK_SECRET;
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.error("Error verifying webhook signature:", err);
        return res.status(400).send(`Webhook Error: ${err}`);
    }
    // Handle the event
    switch (event.type) {
        case "checkout.session.completed":
            completeTransaction(event);
            break;
        case "checkout.session.async_payment_failed":
            console.log("Payment failed:", event.data.object);
            break;
        default:
    }
    res.status(200).json({ received: true });
});
exports.handleWebhook = handleWebhook;
const completeTransaction = (event) => __awaiter(void 0, void 0, void 0, function* () {
    const session = event.data.object;
    const paymentSession = yield PaymentSession_1.default.findOne({
        sessionId: session.id,
    });
    const subscription = event.data.object.subscription;
    const subStatus = (yield stripe.subscriptions.retrieve(subscription)).status;
    // Sending mail (Waiting for designers to create templates)
    const template_path = path_1.default.join(__dirname, "../templates", "online_coaching_confirmation.html");
    const templateSource = readHTMLFile(template_path);
    const msg = {
        from: "shanemahon@midlandsperformanceclub.ie",
        to: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.email,
        subject: "Subscription Confirmation",
        html: templateSource,
    };
    yield mail_1.default.send(msg);
    console.log('✅ Email sent successfully');
    const subscriber = yield User_1.default.create({
        email: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.email,
        firstName: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.firstName,
        lastName: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.lastName,
        age: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.age,
        customerId: session.customer,
        subscriptionId: session.subscription,
        status: subStatus,
        startDate: new Date(),
        type: "online_coaching",
    });
    (0, notification_1.sendNotificationToAdmin)("New Online Coaching Subscription", `New subscription from ${paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.firstName} ${paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.lastName}`);
    console.log("Payment successful:", session);
});
const readHTMLFile = (filePath) => {
    return fs_1.default.readFileSync(filePath, "utf8");
};
