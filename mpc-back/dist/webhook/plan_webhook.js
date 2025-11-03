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
const mail_1 = __importDefault(require("@sendgrid/mail"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const stripe_1 = __importDefault(require("stripe"));
mail_1.default.setApiKey(process.env.SENDGRID_API_KEY);
const Stripe = new stripe_1.default.Stripe(process.env.NODE_ENV == "development" ? process.env.STRIPE_TEST_SECRET_KEY : process.env.STRIPE_SECRET_KEY);
// Test Stripe Products
const testTrainingPlans = [
    {
        priceId: "price_1RGjQQPrBbVluHtKOJhsfoRW",
        type: "femaleLower",
    },
    {
        priceId: "price_1RGjVtPrBbVluHtKMS8Gj0I5",
        type: "upper",
    },
    {
        priceId: "price_1RGjPmPrBbVluHtKAdUK720a",
        type: "lower",
    },
    {
        priceId: "price_1RGjVPPrBbVluHtKMSq17jrQ",
        type: "ppl",
    }
];
const handlePlanWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const sig = req.headers["stripe-signature"];
    const endpointSecret = process.env.NODE_ENV == "development"
        ? "whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47"
        : process.env.STRIPE_WEBHOOK_SECRET;
    let event;
    try {
        event = stripe_1.default.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.error("Error verifying webhook signature:", err);
        res.status(400).send(`Webhook Error: ${err}`);
    }
    // Handle the event
    switch (event.type) {
        case "checkout.session.completed":
            try {
                completeTransaction(event);
            }
            catch (error) {
                console.error('Error completing transaction:', error);
                res.status(500).send('Internal Server Error');
                return;
            }
            break;
        case "checkout.session.async_payment_failed":
            console.log("Payment failed:", event.data.object);
            break;
        default:
    }
    res.status(200).json({ received: true });
});
exports.handlePlanWebhook = handlePlanWebhook;
function completeTransaction(event) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b, _c;
        const session = event.data.object;
        console.log('✅ Checkout Session Completed:', session.id);
        const lineItems = yield Stripe.checkout.sessions.listLineItems(session.id, { limit: 1 });
        console.log('🛒 Line Items:', lineItems.data);
        const priceId = lineItems.data[0].price.id;
        console.log('PRICE ID:', priceId);
        const type = ((_a = testTrainingPlans.find(plan => plan.priceId === priceId)) === null || _a === void 0 ? void 0 : _a.type) || 'unknown';
        console.log(`🏷️  Purchased Plan Type: ${type}`);
        yield sendTrainingPlanEmail(((_b = session.customer_details) === null || _b === void 0 ? void 0 : _b.email) || '', type, session.id);
        console.log('✅ Training plan email sent to:', (_c = session.customer_details) === null || _c === void 0 ? void 0 : _c.email);
    });
}
function sendTrainingPlanEmail(email, planType, orderNumber) {
    return __awaiter(this, void 0, void 0, function* () {
        const template_path = path_1.default.join(__dirname, "../", "templates", "training_plan.html");
        const templateSource = fs_1.default.readFileSync(template_path, "utf8");
        let html = templateSource.replace("{{planDownloadLink}}", `https://mp-club-production.up.railway.app/web/plans/download-training-plan/${planType}/${process.env.TRAINING_PLAN_DOWNLOAD_TOKEN}`);
        html = html.replace("{{orderNumber}}", orderNumber);
        const msg = {
            to: email,
            from: "shanemahon@midlandsperformanceclub.ie",
            subject: "Your Training Plan is Here!",
            html: html,
        };
        yield mail_1.default.send(msg);
    });
}
