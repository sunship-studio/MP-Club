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
const express_1 = __importDefault(require("express"));
const plans_1 = __importDefault(require("../controllers/web/plans"));
const mail_1 = __importDefault(require("@sendgrid/mail"));
const body_parser_1 = __importDefault(require("body-parser"));
const console_1 = __importDefault(require("console"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const plan_webhook_1 = require("../webhook/plan_webhook");
mail_1.default.setApiKey(process.env.SENDGRID_API_KEY);
// Plans Router
const plansRouter = express_1.default.Router();
const plansController = new plans_1.default();
// Purchase Plan
plansRouter.post("/create-checkout-session", body_parser_1.default.json(), plansController.createCheckoutSession);
const TRAINING_PLANS = {
    femaleLower: 'female-lower.xlsx',
    lower: 'lower.xlsx',
    upper: 'upper.xlsx',
    ppl: 'ppl.xlsx',
};
// webhook for Stripe
plansRouter.post("/webhook", body_parser_1.default.raw({ type: "application/json" }), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
}));
// Download specific training plan
plansRouter.get('/download-training-plan/:planType/:token', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        if (req.params.token !== process.env.TRAINING_PLAN_DOWNLOAD_TOKEN) {
            res.status(403).json({ error: 'Forbidden' });
            return;
        }
        const { planType } = req.params;
        // Validate plan type
        if (!TRAINING_PLANS[planType]) {
            res.status(400).json({
                error: 'Invalid plan type',
                availablePlans: Object.keys(TRAINING_PLANS)
            });
            return;
        }
        // Get the filename
        const filename = TRAINING_PLANS[planType];
        // Path to the template file
        const filePath = path_1.default.join(__dirname, '../../templates/plans', filename);
        console_1.default.log('File path:', filePath);
        // Check if file exists
        if (!fs_1.default.existsSync(filePath)) {
            res.status(404).json({ error: 'Training plan file not found' });
            return;
        }
        // Set headers for download
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        // Stream the file
        const fileStream = fs_1.default.createReadStream(filePath);
        fileStream.pipe(res);
    }
    catch (error) {
        console_1.default.error('Error downloading training plan:', error);
        res.status(500).json({ error: 'Failed to download training plan' });
    }
}));
plansRouter.post("/", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    (0, plan_webhook_1.sendTrainingPlanEmail)("kamryydev@gmail.com", "upper", "1234567890");
    console_1.default.log('✅ Email sent successfully');
    res.status(200).send("Email sent");
}));
exports.default = plansRouter;
