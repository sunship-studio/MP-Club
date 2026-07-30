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
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const stripe_1 = __importDefault(require("../../config/stripe"));
const PaymentSession_1 = __importDefault(require("../../models/PaymentSession"));
const User_1 = __importDefault(require("../../models/User"));
class OnlineCoachingController {
    constructor() {
        // Initialize any properties or dependencies here
    }
    createCheckoutSession(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log('Creating checkout session...');
            console.log('Request body:', req.body);
            const { email, firstName, lastName, age } = req.body;
            try {
                const session = yield stripe_1.default.checkout.sessions.create({
                    payment_method_types: ['card'],
                    payment_method_options: {
                        card: {
                            request_three_d_secure: 'any',
                        },
                    },
                    mode: 'subscription',
                    line_items: [
                        {
                            price: process.env.NODE_ENV == 'production'
                                ? process.env.STRIPE_PRICE_ID
                                : process.env.STRIPE_TEST_PRICE_ID,
                            quantity: 1,
                        },
                    ],
                    metadata: {
                        type: 'online_coaching',
                    },
                    success_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/online-coaching/success`
                        : `https://www.midlandsperformanceclub.ie/online-coaching/success`,
                    cancel_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/online-coaching/`
                        : `https://www.midlandsperformanceclub.ie/online-coaching/`,
                });
                console.log('Session created:', session);
                // Store the session ID in your database or perform any other necessary actions
                yield PaymentSession_1.default.create({
                    sessionId: session.id,
                    email,
                    firstName,
                    lastName,
                    age,
                })
                    .then(() => {
                    console.log('Payment session saved to database');
                })
                    .catch((error) => {
                    console.error('Error saving payment session:', error);
                });
                res.status(200).json({
                    url: session.url,
                });
            }
            catch (error) {
                console.error('Error creating subscription:', error);
                res.status(500).json({ error: 'Failed to create subscription' });
            }
        });
    }
    cancelSubscription(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { email } = req.body;
            try {
                // generate token for the customer
                const customer = yield stripe_1.default.customers.list({
                    email: email,
                });
                if (customer.data.length === 0) {
                    res.status(404).json({ error: 'Customer not found' });
                }
                // Token generation
                const token = yield generateToken(customer.data[0].id);
                const subscriber = yield User_1.default.findOneAndUpdate({ email: email }, { cancelToken: token });
                // Template emails
                const template_path = path_1.default.join(process.cwd(), 'templates', 'online_cancelation.html');
                const templateSource = readHTMLFile(template_path);
                const template = Handlebars.compile(templateSource);
                const htmlToSend = template({
                    cancelUrl: `midlandsperformanceclub.ie/online-coaching/cancel?token=${token}`,
                });
                const mailOptions = {
                    from: process.env.MAIL_FROM,
                    to: email,
                    subject: 'Subscription Cancellation',
                    html: htmlToSend,
                };
                res.status(200);
                console.log('Cancellation email sent to:', email);
            }
            catch (error) {
                console.error('Error deleting subscription:', error);
                res.status(500).json({ error: 'Failed to delete subscription' });
            }
        });
    }
    confirmCancelSubscription(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { token } = req.body;
            console.log('Token received:', token);
            try {
                const subscriber = yield User_1.default.findOne({
                    cancelToken: token,
                });
                if (!subscriber) {
                    res.status(404).json({ error: 'Subscriber not found' });
                    return;
                }
                // Cancel the subscription
                const subscription = yield stripe_1.default.subscriptions.cancel(subscriber.subscriptionId);
                // Delete the subscriber from the database
                yield User_1.default.findOneAndUpdate({ cancelToken: token }, { status: 'canceled' });
                res.status(200).json({ message: 'Subscription cancelled successfully' });
            }
            catch (error) {
                console.error('Error confirming cancellation:', error);
                res.status(500).json({ error: 'Failed to confirm cancellation' });
            }
        });
    }
}
exports.default = OnlineCoachingController;
const readHTMLFile = (filePath) => {
    return fs_1.default.readFileSync(filePath, 'utf8');
};
const generateToken = (customerId) => __awaiter(void 0, void 0, void 0, function* () {
    const token = yield stripe_1.default.tokens.create({
        customer: customerId,
    });
    return token.id;
});
