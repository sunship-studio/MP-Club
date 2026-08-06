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
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const resend_1 = __importDefault(require("../config/resend"));
const stripe_1 = __importDefault(require("../config/stripe"));
const PaymentSession_1 = __importDefault(require("../models/PaymentSession"));
const User_1 = __importDefault(require("../models/User"));
const notification_1 = require("../services/notification");
// Each Stripe webhook endpoint has its own signing secret; env vars allow
// rotation without a deploy, hardcoded values are the current live/dev secrets.
const endpointSecret = process.env.NODE_ENV == 'development'
    ? process.env.STRIPE_COACHING_WEBHOOK_SECRET_DEV ||
        'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
    : process.env.STRIPE_COACHING_WEBHOOK_SECRET ||
        'whsec_yIFQOy0GjJtbZSPfz1eO3IrO3qPBuozh';
const handleWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c;
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        event = stripe_1.default.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.error('Error verifying webhook signature:', err);
        return res.status(400).send(`Webhook Error: ${err}`);
    }
    // Handle the event
    switch (event.type) {
        case 'checkout.session.completed':
            completeTransaction(event);
            break;
        case 'checkout.session.async_payment_failed':
            console.log('Payment failed:', event.data.object);
            break;
        case 'checkout.session.expired': {
            const expired = event.data.object;
            console.log('Checkout session expired:', expired.id, 'customer:', expired.customer, 'email:', expired.customer_email || ((_a = expired.customer_details) === null || _a === void 0 ? void 0 : _a.email));
            break;
        }
        case 'invoice.payment_failed': {
            const invoice = event.data.object;
            console.error('Invoice payment failed:', invoice.id, 'customer:', invoice.customer, 'subscription:', invoice.subscription, 'reason:', ((_b = invoice.last_finalization_error) === null || _b === void 0 ? void 0 : _b.message) ||
                ((_c = invoice.last_payment_error) === null || _c === void 0 ? void 0 : _c.message) ||
                'unknown');
            break;
        }
        default:
    }
    res.status(200).json({ received: true });
});
exports.handleWebhook = handleWebhook;
const completeTransaction = (event) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const session = event.data.object;
    // Only process online coaching sessions
    if (((_a = session.metadata) === null || _a === void 0 ? void 0 : _a.type) !== 'online_coaching') {
        console.log('Skipping non-online-coaching session:', session.id);
        return;
    }
    const paymentSession = yield PaymentSession_1.default.findOne({
        sessionId: session.id,
    });
    if (!paymentSession) {
        console.error('Payment session not found for:', session.id);
        return;
    }
    const subscription = event.data.object.subscription;
    const subStatus = (yield stripe_1.default.subscriptions.retrieve(subscription)).status;
    // Sending mail (Waiting for designers to create templates)
    const template_path = path_1.default.join(process.cwd(), 'templates', 'online_coaching_confirmation.html');
    const templateSource = readHTMLFile(template_path);
    const htmlContent = templateSource.replace('{{firstName}}', (paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.firstName) || '');
    const { data, error } = yield resend_1.default.emails.send({
        from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
        to: [(paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.email) || ''],
        subject: 'Subscription Confirmation',
        html: htmlContent,
    });
    if (error) {
        console.error('Error sending email:', error);
    }
    else {
        console.log('✅ Email sent successfully:', data);
    }
    const subscriber = yield User_1.default.create({
        email: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.email,
        firstName: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.firstName,
        lastName: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.lastName,
        age: paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.age,
        customerId: session.customer,
        subscriptionId: session.subscription,
        status: subStatus,
        startDate: new Date(),
        type: 'online_coaching',
    });
    (0, notification_1.sendNotificationToAdmin)('New Online Coaching Subscription', `New subscription from ${paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.firstName} ${paymentSession === null || paymentSession === void 0 ? void 0 : paymentSession.lastName}`);
    console.log('Payment successful:', session);
});
const readHTMLFile = (filePath) => {
    return fs_1.default.readFileSync(filePath, 'utf8');
};
