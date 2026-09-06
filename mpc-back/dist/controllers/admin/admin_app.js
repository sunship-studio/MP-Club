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
const console_1 = __importDefault(require("console"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const cloudinary_1 = require("../../config/cloudinary");
const resend_1 = __importDefault(require("../../config/resend"));
const stripe_1 = __importDefault(require("../../config/stripe"));
const AdminSettings_1 = __importDefault(require("../../models/AdminSettings"));
const ClassPass_1 = __importDefault(require("../../models/ClassPass"));
const ClassPassProduct_1 = __importDefault(require("../../models/ClassPassProduct"));
const Exercise_1 = __importDefault(require("../../models/Exercise"));
const GroupClass_1 = __importDefault(require("../../models/GroupClass"));
const PlanForSale_1 = require("../../models/PlanForSale");
const class_pass_1 = require("../../services/class_pass");
const class_pass_email_1 = require("../../services/class_pass_email");
const group_class_booking_1 = require("../../services/group_class_booking");
const User_1 = __importDefault(require("../../models/User"));
const WaitingListEntry_1 = require("../../models/WaitingListEntry");
const excel_1 = __importDefault(require("../../services/excel"));
class AdminAppController {
    constructor() {
        this.readHTMLFile = (filePath) => {
            return fs_1.default.readFileSync(filePath, 'utf8');
        };
    }
    /**
     * Who holds a pass and when it runs out.
     *
     * Tokens are deliberately absent: they are bearer credentials, and an admin
     * list is a screen that gets screenshotted and shared. Shane gets a holder
     * back onto their pass with `resendClassPassLink` instead (D8).
     */
    listClassPasses(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const search = typeof req.query.search === 'string' ? req.query.search.trim() : '';
                const filter = search
                    ? { email: { $regex: search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
                    : {};
                const passes = yield ClassPass_1.default.find(filter).sort({ purchasedAt: -1 }).lean();
                const today = (0, class_pass_1.venueToday)();
                const products = yield ClassPassProduct_1.default.find().lean();
                const productName = new Map(products.map((p) => [String(p._id), p.name]));
                return res.status(200).json(passes.map((pass) => {
                    var _a;
                    return ({
                        _id: pass._id,
                        firstName: pass.firstName,
                        lastName: pass.lastName,
                        email: pass.email,
                        productName: (_a = productName.get(String(pass.productId))) !== null && _a !== void 0 ? _a : `${pass.months} Month Pass`,
                        months: pass.months,
                        pricePaidCents: pass.pricePaidCents,
                        validFromDate: pass.validFromDate,
                        validUntilDate: pass.validUntilDate,
                        purchasedAt: pass.purchasedAt,
                        grantedByAdmin: pass.grantedByAdmin,
                        // Renewal state, so an admin can see what is still being charged
                        // (D19). The subscription id itself stays server-side — the admin
                        // app has no use for it and it is a Stripe handle.
                        recurring: Boolean(pass.stripeSubscriptionId),
                        autoRenew: Boolean(pass.autoRenew),
                        subscriptionStatus: pass.subscriptionStatus,
                        nextChargeDate: pass.nextChargeDate,
                        status: pass.revoked
                            ? 'revoked'
                            : pass.validUntilDate < today
                                ? 'expired'
                                : 'active',
                    });
                }));
            }
            catch (error) {
                console_1.default.error('Error listing class passes:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    /** The products a grant can be made against. */
    getPassProductsForAdmin(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const products = yield ClassPassProduct_1.default.find({ active: true }).lean();
                return res.status(200).json(products);
            }
            catch (error) {
                console_1.default.error('Error listing class pass products:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    /**
     * Grant a pass by hand. The failure this exists for: Stripe took the money,
     * the webhook didn't land, and a customer who turned up has no pass (D12).
     */
    grantClassPass(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { productId, firstName, lastName } = req.body;
                const email = (_a = req.body.email) === null || _a === void 0 ? void 0 : _a.trim().toLowerCase();
                if (!productId || !email || !firstName) {
                    return res.status(400).json({ message: 'Missing required fields' });
                }
                const product = yield ClassPassProduct_1.default.findById(productId);
                if (!product) {
                    return res.status(404).json({ message: 'Class pass product not found' });
                }
                // Same one-at-a-time rule as a purchase (D7), which is also what stops a
                // double tap on the grant button minting two passes.
                const held = yield (0, class_pass_1.findActivePassForEmail)(email);
                if (held) {
                    return res.status(409).json({
                        error: `${email} already has a pass, valid until ${held.validUntilDate}.`,
                        validUntilDate: held.validUntilDate,
                    });
                }
                const pass = yield (0, class_pass_1.activatePass)({
                    productId: String(product._id),
                    email,
                    firstName,
                    lastName,
                    purchaseDate: (0, class_pass_1.venueToday)(),
                    grantedByAdmin: true,
                });
                // The grant is the point; the email is a courtesy. Shane fixing a
                // customer in front of him must not fail because Resend is down — he can
                // resend from the list once it is back.
                let emailSent = true;
                try {
                    yield (0, class_pass_email_1.sendPassLinkEmail)(pass);
                }
                catch (error) {
                    emailSent = false;
                    console_1.default.error('Granted pass but failed to email the link:', error);
                }
                return res.status(201).json({
                    _id: pass._id,
                    email: pass.email,
                    validFromDate: pass.validFromDate,
                    validUntilDate: pass.validUntilDate,
                    emailSent,
                });
            }
            catch (error) {
                console_1.default.error('Error granting class pass:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    /**
     * Revoke or un-revoke a pass.
     *
     * Revoking blocks new bookings and moves no spots: classes already booked
     * stand, and Shane removes an attendee deliberately in the editor if he wants
     * them gone. A misclick is fixed by un-revoking, not by reconstructing
     * somebody's calendar (D9).
     */
    setClassPassRevoked(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const revoked = ((_a = req.body) === null || _a === void 0 ? void 0 : _a.revoked) !== false;
                const pass = yield ClassPass_1.default.findByIdAndUpdate(req.params.id, { $set: { revoked } }, { new: true });
                if (!pass) {
                    return res.status(404).json({ message: 'Class pass not found' });
                }
                // Revoking has to stop the money as well as the entitlement: a revoked
                // pass that keeps billing monthly is a bug with a bank statement
                // attached (D19). Cancelled outright, not at period end — there is no
                // term left to honour once the pass is withdrawn.
                let subscriptionCancelFailed = false;
                const stillCharging = revoked &&
                    pass.stripeSubscriptionId &&
                    pass.subscriptionStatus !== 'canceled';
                if (stillCharging) {
                    try {
                        yield stripe_1.default.subscriptions.cancel(pass.stripeSubscriptionId);
                    }
                    catch (error) {
                        // The entitlement is ours to withdraw and has been. Billing is a
                        // best effort, and a failure here must be visible rather than leave
                        // the pass live.
                        console_1.default.error('Failed to cancel subscription for revoked pass:', error);
                        subscriptionCancelFailed = true;
                    }
                    pass.autoRenew = false;
                    pass.subscriptionStatus = 'canceled';
                    pass.nextChargeDate = undefined;
                    yield pass.save();
                }
                return res.status(200).json(Object.assign({ _id: pass._id, revoked: pass.revoked, 
                    // Un-revoking restores the pass but never the subscription: resuming a
                    // cancelled one would need a card, and we hold none.
                    subscriptionEnded: pass.subscriptionStatus === 'canceled' }, (subscriptionCancelFailed ? { subscriptionCancelFailed: true } : {})));
            }
            catch (error) {
                console_1.default.error('Error updating class pass:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    /** Resend a holder their current pass link, so a lost email is self-service. */
    resendClassPassLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const pass = yield ClassPass_1.default.findById(req.params.id);
                if (!pass) {
                    return res.status(404).json({ message: 'Class pass not found' });
                }
                yield (0, class_pass_email_1.sendPassLinkEmail)(pass);
                return res.status(200).json({ sent: true, email: pass.email });
            }
            catch (error) {
                console_1.default.error('Error resending class pass link:', error);
                return res.status(500).json({ message: 'Failed to send the pass email' });
            }
        });
    }
    getAllExercises(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const exercises = yield Exercise_1.default.find();
                return res.status(200).json(exercises);
            }
            catch (error) {
                console_1.default.error('Error fetching exercises:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const waitingList = yield WaitingListEntry_1.WaitingListEntry.find();
                if (!waitingList || waitingList.length === 0) {
                    return res.status(404).json({ message: 'No entries found' });
                }
                // Sort the waiting list by createdAt in descending order
                waitingList.sort((a, b) => {
                    return b.dateApplied.getTime() - a.dateApplied.getTime();
                });
                return res.status(200).json(waitingList);
            }
            catch (error) {
                console_1.default.error('Error fetching waiting list:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    saveTrainingPlan(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId, trainingPlan } = req.body;
                const user = yield User_1.default.findById(userId);
                if (!user) {
                    return res.status(404).json({ message: 'User not found' });
                }
                console_1.default.log('Training Plan to be saved:', trainingPlan.days[0].exercises);
                for (const day of trainingPlan.days) {
                    for (const exercise of day.exercises) {
                        console_1.default.log('Exercise in plan:', exercise);
                        const matchedExercise = yield Exercise_1.default.findById(exercise.exerciseId);
                        console_1.default.log('Matched Exercise:', matchedExercise);
                        if (matchedExercise && matchedExercise.videoUrl) {
                            exercise.videoUrl = matchedExercise.videoUrl;
                        }
                        console_1.default.log('Final Exercise to be saved:', exercise);
                    }
                }
                user.trainingPlan = trainingPlan;
                user.trainingPlan.lastUpdated = new Date();
                yield user.save();
                return res.status(200).json({ message: 'Training plan saved' });
            }
            catch (error) {
                console_1.default.error('Error saving training plan:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscriptions = yield User_1.default.find();
                console_1.default.log('Subscriptions:', subscriptions);
                return res.status(200).json(subscriptions);
            }
            catch (error) {
                console_1.default.error('Error fetching online subscriptions:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getOnlineCoachingUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const users = yield User_1.default.find({ type: 'online_coaching' });
                return res.status(200).json(users);
            }
            catch (error) {
                console_1.default.error('Error fetching online coaching users:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    rejectWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const entry = yield WaitingListEntry_1.WaitingListEntry.findById(id);
                if (!entry) {
                    return res.status(404).json({ message: 'Entry not found' });
                }
                entry.approvalStatus = 'rejected';
                yield entry.save();
                return res.status(200).json({ message: 'Entry rejected' });
            }
            catch (error) {
                console_1.default.error('Error rejecting waiting list entry:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    acceptWaitingList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const entry = yield WaitingListEntry_1.WaitingListEntry.findById(id);
                if (!entry) {
                    return res.status(404).json({ message: 'Entry not found' });
                }
                entry.approvalStatus = 'approved';
                entry.approvedDate = new Date();
                yield entry.save();
                return res.status(200).json({ message: 'Entry approved' });
            }
            catch (error) {
                console_1.default.error('Error approving waiting list entry:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    saveUserCalories(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id, calories } = req.body;
                const user = yield User_1.default.findById(id);
                if (!user) {
                    return res.status(404).json({ message: 'User not found' });
                }
                user.caloriesPerDay = calories;
                yield user.save();
                return res.status(200).json({ message: 'Calories updated' });
            }
            catch (error) {
                console_1.default.error('Error updating user calories:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    saveUserTargetWeight(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id, targetWeight } = req.body;
                const user = yield User_1.default.findById(id);
                if (!user) {
                    console_1.default.log('User not found with id:', id);
                    return res.status(404).json({ message: 'User not found' });
                }
                user.targetWeight = targetWeight;
                yield user.save();
                return res.status(200).json({ message: 'Target weight updated' });
            }
            catch (error) {
                console_1.default.error('Error updating user target weight:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    saveAdminFCMToken(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { fcmToken } = req.body;
                AdminSettings_1.default.create({
                    key: 'admin_fcm_token',
                    value: fcmToken,
                });
                return res.status(200).json({ message: 'FCM token updated' });
            }
            catch (error) {
                console_1.default.error('Error updating admin FCM token:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    addSubscriber(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { firstName, lastName, age } = req.body;
                const email = String((_a = req.body.email) !== null && _a !== void 0 ? _a : '').trim().toLowerCase();
                if (!email) {
                    return res.status(400).json({ message: 'Email is required' });
                }
                const existingUser = yield User_1.default.findOne({
                    email: { $regex: `^${email.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
                });
                if (existingUser) {
                    return res.status(400).json({
                        message: `User with email ${existingUser.email} already exists (status: ${existingUser.status}, type: ${existingUser.type})`,
                    });
                }
                yield User_1.default.create({
                    email,
                    firstName,
                    lastName,
                    age,
                    type: 'online_coaching',
                    customerId: 'manual_subscriber',
                    subscriptionId: 'manual_subscriber',
                    status: 'active',
                    startDate: new Date(),
                });
                // Send confirmation only after the subscriber is actually created
                const template_path = path_1.default.join(process.cwd(), 'templates', 'online_coaching_confirmation.html');
                const templateSource = this.readHTMLFile(template_path);
                const { data, error } = yield resend_1.default.emails.send({
                    from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
                    to: [email],
                    subject: 'Subscription Confirmation',
                    html: templateSource,
                });
                if (error) {
                    console_1.default.error('Error sending email:', error);
                }
                else {
                    console_1.default.log('✅ Email sent successfully:', data);
                }
                return res.status(200).json({ message: 'Subscriber added' });
            }
            catch (error) {
                console_1.default.error('Error adding subscriber:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getTrainingPlans(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console_1.default.log('Fetching training plans...');
                const trainingPlans = yield PlanForSale_1.PlanForSale.find();
                return res.status(200).json(trainingPlans);
            }
            catch (error) {
                console_1.default.error('Error fetching training plans:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    editTrainingPlan(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id, updatedPlan } = req.body;
                const trainingPlan = yield PlanForSale_1.PlanForSale.findById(id);
                if (!trainingPlan) {
                    res.status(404).json({ message: 'Training plan not found' });
                    return;
                }
                console_1.default.log('Updated Plan:', updatedPlan.days[0].exercises);
                trainingPlan.name = updatedPlan.name;
                trainingPlan.price = updatedPlan.price;
                trainingPlan.days = updatedPlan.days;
                const newExcelFile = yield excel_1.default.generateBufferFromTemplate(trainingPlan, {
                    templatePath: path_1.default.join(__dirname, '../../../templates/training_plan.xlsx'),
                });
                const uploadResponse = yield (0, cloudinary_1.uploadExcelToCloudinary)(newExcelFile, `${trainingPlan._id}_training_plan.xlsx`, 'training_plans');
                trainingPlan.excelFileUrl = uploadResponse.url;
                yield trainingPlan.save();
                res.status(200).json({ message: 'Training plan updated' });
            }
            catch (error) {
                console_1.default.error('Error editing training plan:', error);
            }
        });
    }
    deleteTrainingPlan(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const trainingPlan = yield PlanForSale_1.PlanForSale.findById(id);
                if (!trainingPlan) {
                    res.status(404).json({ message: 'Training plan not found' });
                    return;
                }
                yield PlanForSale_1.PlanForSale.findByIdAndDelete(id);
                res.status(200).json({ message: 'Training plan deleted' });
            }
            catch (error) {
                console_1.default.error('Error deleting training plan:', error);
            }
        });
    }
    addPlanForSell(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { name, days, price, currency = 'eur' } = req.body;
                // Create Stripe product
                const stripeProduct = yield stripe_1.default.products.create({
                    name: name,
                    description: `Training plan: ${name}`,
                    metadata: {
                        type: 'training_plan',
                    },
                });
                // Create Stripe price for the product
                const stripePrice = yield stripe_1.default.prices.create({
                    product: stripeProduct.id,
                    unit_amount: Math.round(price * 100), // Convert to cents
                    currency: currency,
                });
                // Save training plan with Stripe product ID
                const newPlan = new PlanForSale_1.PlanForSale({
                    name,
                    price,
                    days,
                    priceId: stripePrice.id,
                    stripeProductId: stripeProduct.id,
                });
                const excelFile = yield excel_1.default.generateBufferFromTemplate(newPlan, {
                    templatePath: path_1.default.join(__dirname, '../../../templates/training_plan.xlsx'),
                });
                const uploadResponse = yield (0, cloudinary_1.uploadExcelToCloudinary)(excelFile, `${newPlan._id}_training_plan.xlsx`, 'training_plans');
                newPlan.excelFileUrl = uploadResponse.url;
                yield newPlan.save();
                console_1.default.log(`✅ Training plan created with Stripe Product ID: ${stripeProduct.id}`);
                return res.status(200).json({
                    message: 'Training plan added',
                    productId: stripeProduct.id,
                    priceId: stripePrice.id,
                });
            }
            catch (error) {
                console_1.default.error('Error adding training plan:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getGroupClasses(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            console_1.default.log('Fetching group classes...');
            const groupClasses = yield GroupClass_1.default.find();
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            // Calculate next date for recurring classes
            const updatedClasses = groupClasses.map((groupClass) => {
                let classDate = groupClass.date;
                if (groupClass.recurring && groupClass.dayOfWeek) {
                    const nextDate = this.getNextDayOfWeek(groupClass.dayOfWeek);
                    classDate = nextDate;
                }
                // Check if class is today
                const classDayStart = new Date(classDate);
                classDayStart.setHours(0, 0, 0, 0);
                const isToday = classDayStart.getTime() === today.getTime();
                const obj = groupClass.toObject();
                // For recurring classes, only show attendees for the upcoming occurrence —
                // each week is its own pool. Pending (unpaid) holds are excluded from the
                // roster; confirmed and legacy bookings are kept.
                if (groupClass.recurring && groupClass.dayOfWeek && classDate) {
                    const occ = (0, group_class_booking_1.toLocalDateString)(new Date(classDate));
                    obj.timeSlots = obj.timeSlots.map((slot) => (Object.assign(Object.assign({}, slot), { spots: (slot.spots || []).filter((s) => s.occurrenceDate === occ && s.status !== 'pending') })));
                }
                return Object.assign(Object.assign({}, obj), { date: classDate, isToday });
            });
            return res.json(updatedClasses);
        });
    }
    getNextDayOfWeek(dayOfWeek) {
        const daysOfWeek = [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
        ];
        const targetDay = daysOfWeek.indexOf(dayOfWeek);
        if (targetDay === -1) {
            // If day not found, return current date
            return new Date();
        }
        const today = new Date();
        const currentDay = today.getDay();
        // Calculate days until next occurrence (today counts — a class on its own
        // weekday is "today", matching the public calendar which keeps today bookable)
        let daysUntilTarget = targetDay - currentDay;
        if (daysUntilTarget < 0) {
            daysUntilTarget += 7; // Move to next week
        }
        // Create next date
        const nextDate = new Date(today);
        nextDate.setDate(today.getDate() + daysUntilTarget);
        nextDate.setHours(0, 0, 0, 0); // Reset time to midnight
        return nextDate;
    }
    createGroupClass(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { title, durationMinutes, timeSlots, date, spotsAvailable, recurring, dayOfWeek, } = req.body;
                const newGroupClass = new GroupClass_1.default({
                    title,
                    durationMinutes,
                    timeSlots,
                    date,
                    recurring,
                    dayOfWeek,
                    spotsAvailable,
                });
                yield newGroupClass.save();
                return res
                    .status(200)
                    .json({ message: 'Group class created', groupClass: newGroupClass });
            }
            catch (error) {
                console_1.default.error('Error creating group class:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    editGroupClass(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { _id, title, durationMinutes, timeSlots, date, spotsAvailable, recurring, dayOfWeek, } = req.body;
                const groupClass = yield GroupClass_1.default.findById(_id);
                if (!groupClass) {
                    return res.status(404).json({ message: 'Group class not found' });
                }
                groupClass.title = title;
                groupClass.durationMinutes = durationMinutes;
                // The admin editor only ever sees one occurrence's attendees (the upcoming
                // week for recurring classes) and its spots carry no occurrenceDate/status.
                // Overwriting timeSlots wholesale would therefore destroy every other
                // week's bookings and any in-flight pending holds. Instead, merge: keep the
                // bookings the editor never saw, and treat the editor's list as
                // authoritative only for the edited occurrence (so removals still work).
                const editedOcc = recurring && dayOfWeek
                    ? (0, group_class_booking_1.toLocalDateString)(this.getNextDayOfWeek(dayOfWeek))
                    : date
                        ? (0, group_class_booking_1.toLocalDateString)(new Date(date))
                        : undefined;
                if (editedOcc) {
                    const existingByTime = new Map();
                    for (const slot of groupClass.timeSlots) {
                        existingByTime.set(slot.time, slot.spots || []);
                    }
                    groupClass.timeSlots = timeSlots.map((slot) => {
                        const prior = existingByTime.get(slot.time) || [];
                        // Bookings the editor didn't see: other weeks + live pending holds.
                        const preserved = prior.filter((s) => s.occurrenceDate !== editedOcc || s.status === 'pending');
                        // Editor's list for this occurrence (re-stamped, since the app strips
                        // occurrenceDate/status off spots).
                        const incoming = (slot.spots || []).map((s) => ({
                            firstName: s.firstName,
                            lastName: s.lastName,
                            email: s.email,
                            bookedAt: s.bookedAt || new Date(),
                            occurrenceDate: editedOcc,
                            status: 'confirmed',
                        }));
                        return { time: slot.time, spots: [...preserved, ...incoming] };
                    });
                }
                else {
                    groupClass.timeSlots = timeSlots;
                }
                groupClass.date = date;
                groupClass.spotsAvailable = spotsAvailable;
                if (recurring !== undefined)
                    groupClass.recurring = recurring;
                if (dayOfWeek)
                    groupClass.dayOfWeek = dayOfWeek;
                yield groupClass.save();
                console_1.default.log('Group class updated:', groupClass);
                return res
                    .status(200)
                    .json({ message: 'Group class updated', groupClass });
            }
            catch (error) {
                console_1.default.error('Error editing group class:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    deleteGroupClass(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const groupClass = yield GroupClass_1.default.findById(id);
                if (!groupClass) {
                    return res.status(404).json({ message: 'Group class not found' });
                }
                yield GroupClass_1.default.findByIdAndDelete(id);
                return res.status(200).json({ message: 'Group class deleted' });
            }
            catch (error) {
                console_1.default.error('Error deleting group class:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    // ============ EXERCISE CRUD METHODS ============
    createExercise(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { name, description, bodyParts } = req.body;
                const files = req.files;
                if (!name || !bodyParts) {
                    return res
                        .status(400)
                        .json({ message: 'Name and body parts are required' });
                }
                let videoUrl;
                let imageUrl;
                let videoLengthSeconds;
                // Upload video if provided
                if ((files === null || files === void 0 ? void 0 : files.video) && files.video[0]) {
                    const videoFile = files.video[0];
                    const videoResult = yield (0, cloudinary_1.uploadVideoToCloudinary)(videoFile.buffer, videoFile.originalname, 'exercises');
                    videoUrl = videoResult.url;
                    videoLengthSeconds = videoResult.duration
                        ? Math.round(videoResult.duration)
                        : undefined;
                    console_1.default.log('Video uploaded:', videoUrl);
                }
                // Upload image if provided
                if ((files === null || files === void 0 ? void 0 : files.image) && files.image[0]) {
                    const imageFile = files.image[0];
                    const imageResult = yield (0, cloudinary_1.uploadToCloudinary)(imageFile.buffer, imageFile.originalname, 'exercise-images');
                    imageUrl = imageResult.url;
                    console_1.default.log('Image uploaded:', imageUrl);
                }
                const parsedBodyParts = typeof bodyParts === 'string' ? JSON.parse(bodyParts) : bodyParts;
                const exercise = new Exercise_1.default({
                    name,
                    description,
                    bodyParts: parsedBodyParts,
                    videoUrl,
                    imageUrl,
                    videoLengthSeconds,
                });
                yield exercise.save();
                console_1.default.log('Exercise created:', exercise);
                return res.status(201).json({ message: 'Exercise created', exercise });
            }
            catch (error) {
                console_1.default.error('Error creating exercise:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    updateExercise(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id, name, description, bodyParts, existingVideoUrl, existingImageUrl, } = req.body;
                const files = req.files;
                const exercise = yield Exercise_1.default.findById(id);
                if (!exercise) {
                    return res.status(404).json({ message: 'Exercise not found' });
                }
                // Update basic fields
                if (name)
                    exercise.name = name;
                if (description !== undefined)
                    exercise.description = description;
                if (bodyParts) {
                    exercise.bodyParts =
                        typeof bodyParts === 'string' ? JSON.parse(bodyParts) : bodyParts;
                }
                // Upload new video if provided
                if ((files === null || files === void 0 ? void 0 : files.video) && files.video[0]) {
                    const videoFile = files.video[0];
                    const videoResult = yield (0, cloudinary_1.uploadVideoToCloudinary)(videoFile.buffer, videoFile.originalname, 'exercises');
                    exercise.videoUrl = videoResult.url;
                    exercise.videoLengthSeconds = videoResult.duration
                        ? Math.round(videoResult.duration)
                        : undefined;
                    console_1.default.log('Video updated:', exercise.videoUrl);
                }
                else if (existingVideoUrl) {
                    exercise.videoUrl = existingVideoUrl;
                }
                // Upload new image if provided
                if ((files === null || files === void 0 ? void 0 : files.image) && files.image[0]) {
                    const imageFile = files.image[0];
                    const imageResult = yield (0, cloudinary_1.uploadToCloudinary)(imageFile.buffer, imageFile.originalname, 'exercise-images');
                    exercise.imageUrl = imageResult.url;
                    console_1.default.log('Image updated:', exercise.imageUrl);
                }
                else if (existingImageUrl) {
                    exercise.imageUrl = existingImageUrl;
                }
                yield exercise.save();
                console_1.default.log('Exercise updated:', exercise);
                return res.status(200).json({ message: 'Exercise updated', exercise });
            }
            catch (error) {
                console_1.default.error('Error updating exercise:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    deleteExercise(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.body;
                const exercise = yield Exercise_1.default.findById(id);
                if (!exercise) {
                    return res.status(404).json({ message: 'Exercise not found' });
                }
                yield Exercise_1.default.findByIdAndDelete(id);
                console_1.default.log('Exercise deleted:', id);
                return res.status(200).json({ message: 'Exercise deleted' });
            }
            catch (error) {
                console_1.default.error('Error deleting exercise:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
}
exports.default = AdminAppController;
