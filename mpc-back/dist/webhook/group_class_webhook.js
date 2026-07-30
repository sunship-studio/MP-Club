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
exports.handleGroupClassWebhook = void 0;
const stripe_1 = __importDefault(require("stripe"));
const GroupClass_1 = __importDefault(require("../models/GroupClass"));
const group_classes_1 = require("../routes/group_classes");
const group_class_booking_1 = require("../services/group_class_booking");
const stripe = new stripe_1.default(process.env.NODE_ENV === 'development'
    ? process.env.STRIPE_TEST_SECRET_KEY
    : process.env.STRIPE_SECRET_KEY);
// Webhook endpoint secret - you'll need to set this up in Stripe dashboard
const endpointSecret = process.env.NODE_ENV === 'development'
    ? 'whsec_4495b0404ed8c74eb68af4cda973b84e7b44fc4ef7106c6682a567706594fc47'
    : 'whsec_M8tsimlpTL3EclroIrWp6NRmiYddUNtO';
const handleGroupClassWebhook = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const sig = req.headers['stripe-signature'];
    let event;
    try {
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    }
    catch (err) {
        console.error('⚠️ Webhook signature verification failed:', err.message);
        res.status(400).send(`Webhook Error: ${err.message}`);
        return;
    }
    // Handle the checkout.session.completed event
    if (event.type === 'checkout.session.completed') {
        const session = event.data.object;
        console.log('✅ Group class payment completed:', session.id);
        // Extract metadata
        const metadata = session.metadata;
        if (!metadata) {
            console.error('No metadata found in session');
            res.status(400).send('No metadata found');
            return;
        }
        const { classId, timeSlot, firstName, lastName, email, date, occurrenceDate, holdId, className, durationMinutes, } = metadata;
        try {
            // Confirm the booking
            yield group_classes_1.groupClassController.confirmBookingAfterPayment(classId, timeSlot, firstName, lastName || '', email, date, className, parseInt(durationMinutes, 10), occurrenceDate, holdId);
            console.log('✅ Booking confirmed for:', email);
        }
        catch (error) {
            console.error('Error confirming booking:', error);
            // Don't return error - Stripe will retry
        }
    }
    // Checkout abandoned/expired — release the pending hold so the spot frees up.
    if (event.type === 'checkout.session.expired') {
        const session = event.data.object;
        const metadata = session.metadata;
        if ((metadata === null || metadata === void 0 ? void 0 : metadata.classId) && (metadata === null || metadata === void 0 ? void 0 : metadata.holdId)) {
            try {
                yield (0, group_class_booking_1.releaseHold)(GroupClass_1.default, metadata.classId, metadata.holdId);
                console.log('🕓 Released expired hold:', metadata.holdId);
            }
            catch (error) {
                console.error('Error releasing expired hold:', error);
            }
        }
    }
    res.status(200).json({ received: true });
});
exports.handleGroupClassWebhook = handleGroupClassWebhook;
