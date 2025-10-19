import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import express, { Express } from "express";
import connectToDatabase from "./config/database";
import adminAppRouter from "./routes/admin_app";
import authRouter from "./routes/mobile_app/auth";
import SocketService from "./services/socket";
import { handleWebhook } from "./webhook";

import http from "http";
import caloriesRouter from "./routes/mobile_app/calories";
import chatRouter from "./routes/mobile_app/chat";
import checkInRouter from "./routes/mobile_app/check_in";
import workoutRouter from "./routes/mobile_app/workout";


// Load environment variables
dotenv.config();

connectToDatabase();
const app: Express = express();
const port = process.env.PORT || 3000;

const httpServer = http.createServer(app);

// app.get("/", async (req: Request, res: Response) => {
//   await Exercise.insertMany(data);
//   res.send("Hello World!");
// });

// Middleware
app.use(cors());
app.use(express.urlencoded({ extended: true }));

app.use("/auth", bodyParser.json());
app.use('/chat', bodyParser.json());
app.use("/admin-app", bodyParser.json());
app.use("/mobile-app", bodyParser.json());





app.use("/mobile-app/auth", authRouter);

app.use("/admin-app", adminAppRouter);
app.use("/mobile-app/check-in", checkInRouter);
app.use("/mobile-app/workout", workoutRouter);
app.use("/mobile-app/chat", chatRouter);
app.use('/admin-app/chat', chatRouter);

app.use('/mobile-app/calories', caloriesRouter);
app.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),
  (req, res) => {
    handleWebhook(req, res);
  }
);

const socketService = new SocketService(httpServer);
// Make socket service available to routes
app.set("socketService", socketService);
// Start server
httpServer.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`WebSocket server running at ws://localhost:${port}`);
});

export default app;
