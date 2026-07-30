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
const stripe_1 = __importDefault(require("../../config/stripe"));
const PlanForSale_1 = require("../../models/PlanForSale");
class PlansController {
    constructor() { }
    getPlans(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Get all training plans from database
                const trainingPlans = yield PlanForSale_1.PlanForSale.find();
                res.status(200).json(trainingPlans);
            }
            catch (error) {
                console.error('Error fetching training plans:', error);
                res.status(500).json({ error: 'Failed to fetch training plans' });
            }
        });
    }
    createCheckoutSession(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log('Creating checkout session...');
            console.log('Request body:', req.body);
            const { priceId } = req.body;
            console.log('Price ID:', priceId);
            try {
                const session = yield stripe_1.default.checkout.sessions.create({
                    payment_method_types: ['card'],
                    payment_method_options: {
                        card: {
                            request_three_d_secure: 'any',
                        },
                    },
                    mode: 'payment',
                    line_items: [
                        {
                            price: priceId,
                            quantity: 1,
                        },
                    ],
                    success_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/plans/success`
                        : `${req.protocol}://${req.get('host')}/plans/success`,
                    cancel_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/plans/`
                        : `${req.protocol}://${req.get('host')}/plans/`,
                });
                console.log('Session created:', session);
                // Store the session ID in your database or perform any other necessary actions
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
}
exports.default = PlansController;
