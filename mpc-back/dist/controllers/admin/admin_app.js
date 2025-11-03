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
const mail_1 = __importDefault(require("@sendgrid/mail"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const Exercise_1 = __importDefault(require("../../models/Exercise"));
const User_1 = __importDefault(require("../../models/User"));
const WaitingListEntry_1 = require("../../models/WaitingListEntry");
mail_1.default.setApiKey(process.env.SENDGRID_API_KEY);
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
                console.error('Error fetching exercises:', error);
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
                console.error('Error fetching waiting list:', error);
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
                console.log('Training Plan to be saved:', trainingPlan.days[0].exercises);
                user.trainingPlan = trainingPlan;
                user.trainingPlan.lastUpdated = new Date();
                yield user.save();
                return res.status(200).json({ message: 'Training plan saved' });
            }
            catch (error) {
                console.error('Error saving training plan:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    getUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscriptions = yield User_1.default.find();
                console.log('Subscriptions:', subscriptions);
                return res.status(200).json(subscriptions);
            }
            catch (error) {
                console.error('Error fetching online subscriptions:', error);
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
                console.error('Error fetching online coaching users:', error);
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
                console.error('Error rejecting waiting list entry:', error);
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
                console.error('Error approving waiting list entry:', error);
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
                console.error('Error updating user calories:', error);
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
                    console.log('User not found with id:', id);
                    return res.status(404).json({ message: 'User not found' });
                }
                user.targetWeight = targetWeight;
                yield user.save();
                return res.status(200).json({ message: 'Target weight updated' });
            }
            catch (error) {
                console.error('Error updating user target weight:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
    addSubscriber(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            // Sending mail (Waiting for designers to create templates)
            const template_path = path_1.default.join(__dirname, '../../../templates', 'online_coaching_confirmation.html');
            const templateSource = this.readHTMLFile(template_path);
            const msg = {
                from: 'shanemahon@midlandsperformanceclub.ie',
                to: req.body.email,
                subject: 'Subscription Confirmation',
                html: templateSource,
            };
            yield mail_1.default.send(msg);
            console.log('✅ Email sent successfully');
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
                console.error('Error adding subscriber:', error);
                return res.status(500).json({ message: 'Internal server error' });
            }
        });
    }
}
exports.default = AdminAppController;
