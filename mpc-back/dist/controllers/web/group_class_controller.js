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
const resend_1 = __importDefault(require("../../config/resend"));
const stripe_1 = __importDefault(require("../../config/stripe"));
const GroupClass_1 = __importDefault(require("../../models/GroupClass"));
// Price for group class booking in cents (€10 = 1000 cents)
const GROUP_CLASS_PRICE_CENTS = 1000;
class GroupClassController {
    getGroupClasses(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const groupClasses = yield GroupClass_1.default.find();
                res.status(200).json(groupClasses);
            }
            catch (error) {
                console.error('Error fetching group classes:', error);
                res.status(500).json({ error: 'Failed to fetch group classes' });
            }
        });
    }
    bookGroupClass(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                //[Log] Booking data:
                // classId: "6964d593e636d7b1bb25cfd6"
                // date: "2026-01-11T23:00:00.000Z"
                // email: "kamryydev@gmail.com"
                // firstName: "IGor"
                // lastName: "Kamrowski"
                // timeSlot: "09:30 AM"
                const { classId, date, email, firstName, lastName, timeSlot } = req.body;
                const groupClass = yield GroupClass_1.default.findById(classId);
                if (!groupClass) {
                    res.status(404).json({ error: 'Group class not found' });
                    return;
                }
                // check by mail
                const timeSlotObj = groupClass.timeSlots.find((slot) => slot.time === timeSlot);
                const bookingExists = timeSlotObj === null || timeSlotObj === void 0 ? void 0 : timeSlotObj.spots.some((booking) => booking.email === email);
                if (bookingExists) {
                    res.status(400).json({ error: 'You have already booked this class' });
                    return;
                }
                // add booking
                timeSlotObj === null || timeSlotObj === void 0 ? void 0 : timeSlotObj.spots.push({
                    email,
                    firstName,
                    lastName,
                    bookedAt: new Date(date),
                });
                yield groupClass.save();
                // Send confirmation email
                try {
                    yield this.sendBookingConfirmationEmail(email, firstName, lastName, groupClass.title, date, timeSlot, groupClass.durationMinutes);
                    console.log('✅ Booking confirmation email sent to:', email);
                }
                catch (emailError) {
                    console.error('Error sending confirmation email:', emailError);
                    // Don't fail the booking if email fails
                }
                res.status(200).json({ message: 'Group class booked successfully' });
            }
            catch (error) {
                console.error('Error booking group class:', error);
                res.status(500).json({ error: 'Failed to book group class' });
            }
        });
    }
    sendBookingConfirmationEmail(email, firstName, lastName, className, classDate, classTime, duration) {
        return __awaiter(this, void 0, void 0, function* () {
            const template_path = path_1.default.join(__dirname, '../../../', 'templates', 'group_class_booking.html');
            const templateSource = fs_1.default.readFileSync(template_path, 'utf8');
            // Format the date nicely
            const formattedDate = new Date(classDate).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
            });
            // Replace template variables
            let html = templateSource.replace('{{className}}', className);
            html = html.replace('{{classDate}}', formattedDate);
            html = html.replace('{{classTime}}', classTime);
            html = html.replace('{{duration}}', duration.toString());
            html = html.replace('{{firstName}}', firstName);
            html = html.replace('{{lastName}}', lastName);
            const { data, error } = yield resend_1.default.emails.send({
                from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
                to: [email],
                subject: `Booking Confirmed: ${className}`,
                html: html,
            });
            if (error) {
                console.error('Error sending email:', error);
                throw error;
            }
            console.log('Email sent successfully:', data);
        });
    }
    // Create Stripe checkout session for group class booking
    createCheckoutSession(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { classId, timeSlot, firstName, lastName, email, date } = req.body;
                if (!classId || !timeSlot || !firstName || !email || !date) {
                    res.status(400).json({ error: 'Missing required fields' });
                    return;
                }
                const groupClass = yield GroupClass_1.default.findById(classId);
                if (!groupClass) {
                    res.status(404).json({ error: 'Group class not found' });
                    return;
                }
                // Check if slot is available
                const timeSlotObj = groupClass.timeSlots.find((slot) => slot.time === timeSlot);
                if (!timeSlotObj) {
                    res.status(400).json({ error: 'Time slot not found' });
                    return;
                }
                if (timeSlotObj.spots.length >= groupClass.spotsAvailable) {
                    res.status(400).json({ error: 'This time slot is fully booked' });
                    return;
                }
                // Check if email already booked
                const bookingExists = timeSlotObj.spots.some((booking) => booking.email === email);
                if (bookingExists) {
                    res.status(400).json({ error: 'You have already booked this class' });
                    return;
                }
                // Format the date for display
                const formattedDate = new Date(date).toLocaleDateString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric',
                });
                // Create Stripe checkout session
                const session = yield stripe_1.default.checkout.sessions.create({
                    payment_method_types: ['card'],
                    mode: 'payment',
                    line_items: [
                        {
                            price_data: {
                                currency: 'eur',
                                product_data: {
                                    name: `${groupClass.title} - Group Class`,
                                    description: `${formattedDate} at ${timeSlot} (${groupClass.durationMinutes} min)`,
                                },
                                unit_amount: GROUP_CLASS_PRICE_CENTS,
                            },
                            quantity: 1,
                        },
                    ],
                    customer_email: email,
                    metadata: {
                        classId,
                        timeSlot,
                        firstName,
                        lastName,
                        email,
                        date,
                        className: groupClass.title,
                        durationMinutes: groupClass.durationMinutes.toString(),
                    },
                    success_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/group-classes/success?session_id={CHECKOUT_SESSION_ID}`
                        : `https://midlandsperformanceclub.ie/group-classes/success?session_id={CHECKOUT_SESSION_ID}`,
                    cancel_url: process.env.NODE_ENV === 'development'
                        ? `http://localhost:3000/group-classes`
                        : `https://midlandsperformanceclub.ie/group-classes`,
                });
                console.log('Checkout session created:', session.id);
                res.status(200).json({ url: session.url, sessionId: session.id });
            }
            catch (error) {
                console.error('Error creating checkout session:', error);
                res.status(500).json({ error: 'Failed to create checkout session' });
            }
        });
    }
    // Handle successful payment - called by webhook
    confirmBookingAfterPayment(classId, timeSlot, firstName, lastName, email, date, className, durationMinutes) {
        return __awaiter(this, void 0, void 0, function* () {
            const groupClass = yield GroupClass_1.default.findById(classId);
            if (!groupClass) {
                throw new Error('Group class not found');
            }
            const timeSlotObj = groupClass.timeSlots.find((slot) => slot.time === timeSlot);
            if (!timeSlotObj) {
                throw new Error('Time slot not found');
            }
            // Double-check booking doesn't already exist
            const bookingExists = timeSlotObj.spots.some((booking) => booking.email === email);
            if (bookingExists) {
                console.log('Booking already exists for:', email);
                return;
            }
            // Add the booking
            timeSlotObj.spots.push({
                email,
                firstName,
                lastName,
                bookedAt: new Date(date),
            });
            yield groupClass.save();
            console.log('✅ Booking confirmed after payment:', email);
            // Send confirmation email
            yield this.sendBookingConfirmationEmail(email, firstName, lastName, className, date, timeSlot, durationMinutes);
        });
    }
}
exports.default = GroupClassController;
