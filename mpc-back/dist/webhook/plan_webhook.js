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
exports.handlePlanWebhook = void 0;
exports.sendTrainingPlanEmail = sendTrainingPlanEmail;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const stripe_1 = __importDefault(require("stripe"));
const resend_1 = __importDefault(require("../config/resend"));
const PlanForSale_1 = require("../models/PlanForSale");
const Stripe = new stripe_1.default.Stripe(process.env.NODE_ENV == 'development'
    ? process.env.STRIPE_TEST_SECRET_KEY
    : process.env.STRIPE_SECRET_KEY);
const endpointSecret = process.env.NODE_ENV == 'development'
    ? 'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
    : 'whsec_ywVFk7OncJcAJsh98SvaaJe8hWJn6BQs';
// Test Stripe Products
const testTrainingPlans = [
    {
        priceId: 'price_1RGjQQPrBbVluHtKOJhsfoRW',
        type: 'femaleLower',
    },
    {
        priceId: 'price_1RGjVtPrBbVluHtKMS8Gj0I5',
        type: 'upper',
    },
    {
        priceId: 'price_1RGjPmPrBbVluHtKAdUK720a',
        type: 'lower',
    },
    {
        priceId: 'price_1RGjVPPrBbVluHtKMSq17jrQ',
        type: 'ppl',
    },
];
const handlePlanWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        event = stripe_1.default.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.error('Error verifying webhook signature:', err);
        res.status(400).send(`Webhook Error: ${err}`);
    }
    // Handle the event
    switch (event.type) {
        case 'checkout.session.completed':
            try {
                completeTransaction(event);
            }
            catch (error) {
                console.error('Error completing transaction:', error);
                res.status(500).send('Internal Server Error');
                return;
            }
            break;
        case 'checkout.session.async_payment_failed':
            console.log('Payment failed:', event.data.object);
            break;
        default:
    }
    res.status(200).json({ received: true });
});
exports.handlePlanWebhook = handlePlanWebhook;
function completeTransaction(event) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b, _c, _d;
        const session = event.data.object;
        // Skip if this is a group class or online coaching session
        if (((_a = session.metadata) === null || _a === void 0 ? void 0 : _a.type) === 'online_coaching' ||
            ((_b = session.metadata) === null || _b === void 0 ? void 0 : _b.classId)) {
            console.log('Skipping non-plan session:', session.id);
            return;
        }
        console.log('✅ Checkout Session Completed:', session.id);
        const lineItems = yield Stripe.checkout.sessions.listLineItems(session.id, {
            limit: 1,
        });
        console.log('🛒 Line Items:', lineItems.data);
        const priceId = lineItems.data[0].price.id;
        console.log('PRICE ID:', priceId);
        // Get product ID from the price
        const price = yield Stripe.prices.retrieve(priceId);
        const productId = typeof price.product === 'string' ? price.product : price.product.id;
        // Find training plan by Stripe product ID
        const trainingPlan = yield PlanForSale_1.PlanForSale.findOne({
            stripeProductId: productId,
        });
        if (!trainingPlan) {
            console.error(`⚠️ No training plan found for product ID: ${productId}`);
            return;
        }
        console.log(`🏷️ Purchased Plan: ${trainingPlan.name}`);
        yield sendTrainingPlanEmail(((_c = session.customer_details) === null || _c === void 0 ? void 0 : _c.email) || '', trainingPlan.name, trainingPlan.excelFileUrl, session.id);
        console.log('✅ Training plan email sent to:', (_d = session.customer_details) === null || _d === void 0 ? void 0 : _d.email);
    });
}
function sendTrainingPlanEmail(email, planName, planFileUrl, orderNumber) {
    return __awaiter(this, void 0, void 0, function* () {
        const template_path = path_1.default.join(process.cwd(), 'templates', 'training_plan.html');
        const templateSource = fs_1.default.readFileSync(template_path, 'utf8');
        let html = templateSource.replace('{{planDownloadLink}}', planFileUrl);
        html = html.replace('{{orderNumber}}', orderNumber);
        html = html.replace('{{planName}}', planName);
        const { data, error } = yield resend_1.default.emails.send({
            from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
            to: [email],
            subject: `Your ${planName} Training Plan is Here!`,
            html: html,
        });
        if (error) {
            console.error('Error sending email:', error);
            throw error;
        }
        console.log('Email sent successfully:', data);
    });
}
