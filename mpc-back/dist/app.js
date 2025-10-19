"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const body_parser_1 = __importDefault(require("body-parser"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const express_1 = __importDefault(require("express"));
const database_1 = __importDefault(require("./config/database"));
const admin_app_1 = __importDefault(require("./routes/admin_app"));
const auth_1 = __importDefault(require("./routes/mobile_app/auth"));
const socket_1 = __importDefault(require("./services/socket"));
const webhook_1 = require("./webhook");
const http_1 = __importDefault(require("http"));
const calories_1 = __importDefault(require("./routes/mobile_app/calories"));
const chat_1 = __importDefault(require("./routes/mobile_app/chat"));
const check_in_1 = __importDefault(require("./routes/mobile_app/check_in"));
const workout_1 = __importDefault(require("./routes/mobile_app/workout"));
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
app.use("/mobile-app/auth", auth_1.default);
app.use("/admin-app", admin_app_1.default);
app.use("/mobile-app/check-in", check_in_1.default);
app.use("/mobile-app/workout", workout_1.default);
app.use("/mobile-app/chat", chat_1.default);
app.use('/admin-app/chat', chat_1.default);
app.use('/mobile-app/calories', calories_1.default);
app.post("/webhook", body_parser_1.default.raw({ type: "application/json" }), (req, res) => {
    (0, webhook_1.handleWebhook)(req, res);
});
const socketService = new socket_1.default(httpServer);
// Make socket service available to routes
app.set("socketService", socketService);
// Start server
httpServer.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
    console.log(`WebSocket server running at ws://localhost:${port}`);
});
exports.default = app;
