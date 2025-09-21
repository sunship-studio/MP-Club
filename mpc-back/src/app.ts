import express, { Express, Request, Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import waitingListRouter from "./routes/waiting_list";
import connectToDatabase from "./config/database";
import onlineCoachingRouter from "./routes/online_coaching";
import mobileAppRouter from "./routes/mobile_app";
import notificationsRouter from "./routes/notifications";
import { sendNotificationToDebug } from "./services/notification";
import plansRouter from "./routes/plans";
import handleWebhook from "./controllers/webhook";
import bodyParser from "body-parser";

// Load environment variables
dotenv.config();

connectToDatabase();
const app: Express = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use("/waiting-list", waitingListRouter);
app.use("/online-coaching", onlineCoachingRouter);
app.use("/mobile-app", mobileAppRouter);
app.use("/notifications", notificationsRouter);
app.use('/plans', plansRouter)
app.get("/test", (req: Request, res: Response) => {
  sendNotificationToDebug(
    "Test notification from the server",
    "Test Notification"
  );
  res.status(200).json({ message: "Test notification sent" });
});
app.post('/webhook',  bodyParser.raw({ type: "application/json" }),  (req: Request, res: Response) => {
  handleWebhook(req, res);
});
app.use(express.json());

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

export default app;
