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
const body_parser_1 = __importDefault(require("body-parser"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const http_1 = __importDefault(require("http"));
const database_1 = __importDefault(require("./config/database"));
const admin_app_1 = __importDefault(require("./routes/admin_app"));
const auth_1 = __importDefault(require("./routes/mobile_app/auth"));
const calories_1 = __importDefault(require("./routes/mobile_app/calories"));
const chat_1 = __importDefault(require("./routes/mobile_app/chat"));
const check_in_1 = __importDefault(require("./routes/mobile_app/check_in"));
const profile_1 = __importDefault(require("./routes/mobile_app/profile"));
const workout_1 = __importDefault(require("./routes/mobile_app/workout"));
const online_coaching_1 = __importDefault(require("./routes/online_coaching"));
const plans_1 = __importDefault(require("./routes/plans"));
const waiting_list_1 = __importDefault(require("./routes/waiting_list"));
const socket_1 = __importDefault(require("./services/socket"));
const online_coaching_webhook_1 = require("./webhook/online_coaching_webhook");
mail_1.default.setApiKey(process.env.SENDGRID_API_KEY);
// Load environment variables
dotenv_1.default.config();
(0, database_1.default)();
const app = (0, express_1.default)();
const port = process.env.PORT || 3000;
const httpServer = http_1.default.createServer(app);
// app.get("/", async (req: Request, res: Response) => {
//   await Exercise.insertMany(data);
//   res.send("Hello World!");
// });
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.urlencoded({ extended: true }));
app.use("/auth", body_parser_1.default.json());
app.use('/chat', body_parser_1.default.json());
app.use("/admin-app", body_parser_1.default.json());
app.use("/mobile-app", body_parser_1.default.json());
app.use('/web', body_parser_1.default.json());
app.use('/web/online-coaching', online_coaching_1.default);
app.use('/web/waiting-list', waiting_list_1.default);
app.use('/web/plans', plans_1.default);
app.use("/mobile-app/auth", auth_1.default);
app.use("/admin-app", admin_app_1.default);
app.use("/mobile-app/check-in", check_in_1.default);
app.use("/mobile-app/workout", workout_1.default);
app.use('/mobile-app/profile', profile_1.default);
app.use("/mobile-app/chat", chat_1.default);
app.use('/admin-app/chat', chat_1.default);
app.use('/mobile-app/calories', calories_1.default);
app.post("/webhook", body_parser_1.default.raw({ type: "application/json" }), (req, res) => {
    (0, online_coaching_webhook_1.handleWebhook)(req, res);
});
const fs_1 = __importDefault(require("fs"));
const plan_webhook_1 = require("./webhook/plan_webhook");
const readHTMLFile = (filePath) => {
    return fs_1.default.readFileSync(filePath, "utf8");
};
app.post("/plan_webhook", body_parser_1.default.raw({ type: "application/json" }), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    (0, plan_webhook_1.handlePlanWebhook)(req, res);
}));
app.post("/", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log('✅ Email sent successfully');
    res.json({ message: "Template test email sent" });
}));
const socketService = new socket_1.default(httpServer);
// Make socket service available to routes
app.set("socketService", socketService);
// Start server
httpServer.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
    console.log(`WebSocket server running at ws://localhost:${port}`);
});
exports.default = app;
