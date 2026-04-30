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
const Exercise_1 = __importDefault(require("../../models/Exercise"));
const GroupClass_1 = __importDefault(require("../../models/GroupClass"));
const PlanForSale_1 = require("../../models/PlanForSale");
const User_1 = __importDefault(require("../../models/User"));
const WaitingListEntry_1 = require("../../models/WaitingListEntry");
const excel_1 = __importDefault(require("../../services/excel"));
class AdminAppController {
    constructor() {
        this.readHTMLFile = (filePath) => {
            return fs_1.default.readFileSync(filePath, 'utf8');
        };
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
            // Sending mail (Waiting for designers to create templates)
            const template_path = path_1.default.join(process.cwd(), 'templates', 'online_coaching_confirmation.html');
            const templateSource = this.readHTMLFile(template_path);
            const { data, error } = yield resend_1.default.emails.send({
                from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
                to: [req.body.email],
                subject: 'Subscription Confirmation',
                html: templateSource,
            });
            if (error) {
                console_1.default.error('Error sending email:', error);
            }
            else {
                console_1.default.log('✅ Email sent successfully:', data);
            }
            try {
                const { email, firstName, lastName, age } = req.body;
                const existingUser = yield User_1.default.findOne({ email });
                if (existingUser) {
                    return res.status(400).json({ message: 'User already exists' });
                }
                const newUser = yield User_1.default.create({
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
                return Object.assign(Object.assign({}, groupClass.toObject()), { date: classDate, isToday });
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
        // Calculate days until next occurrence
        let daysUntilTarget = targetDay - currentDay;
        if (daysUntilTarget <= 0) {
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
                groupClass.timeSlots = timeSlots;
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
