import express, { Express, Request, Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import waitingListRouter from "./routes/waiting_list";
import connectToDatabase from "./config/database";
import onlineCoachingRouter from "./routes/online_coaching";
import mobileAppRouter from "./routes/mobile_app";

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

app.use(express.json());

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

export default app;
