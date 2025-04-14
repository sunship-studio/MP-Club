"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const waiting_list_1 = __importDefault(require("./routes/waiting_list"));
const database_1 = __importDefault(require("./config/database"));
const online_coaching_1 = __importDefault(require("./routes/online_coaching"));
const mobile_app_1 = __importDefault(require("./routes/mobile_app"));
// Load environment variables
dotenv_1.default.config();
(0, database_1.default)();
const app = (0, express_1.default)();
const port = process.env.PORT || 3000;
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
app.use("/waiting-list", waiting_list_1.default);
app.use("/online-coaching", online_coaching_1.default);
app.use("/mobile-app", mobile_app_1.default);
// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
exports.default = app;
