import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';
import express, { Express } from 'express';
import http from 'http';
import connectToDatabase from './config/database';
import adminAppRouter from './routes/admin_app';
import groupClassRouter from './routes/group_classes';
import authRouter from './routes/mobile_app/auth';
import caloriesRouter from './routes/mobile_app/calories';
import chatRouter from './routes/mobile_app/chat';
import checkInRouter from './routes/mobile_app/check_in';
import { exerciseRouter } from './routes/mobile_app/exercise';
import profileRouter from './routes/mobile_app/profile';
import workoutRouter from './routes/mobile_app/workout';
import notificationsRouter from './routes/notifications';
import onlineCoachingRouter from './routes/online_coaching';
import plansRouter from './routes/plans';
import waitingListRouter from './routes/waiting_list';
import SocketService from './services/socket';
import { handleWebhook } from './webhook/online_coaching_webhook';
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

app.use('/auth', bodyParser.json());
app.use('/chat', bodyParser.json());
app.use('/admin-app', bodyParser.json());
app.use('/mobile-app', bodyParser.json());
app.use('/web', bodyParser.json());

app.use('/web/online-coaching', onlineCoachingRouter);
app.use('/web/waiting-list', waitingListRouter);
app.use('/web/plans', plansRouter);
app.use('/web/group-classes', groupClassRouter);

app.use('/mobile-app/auth', authRouter);

app.use('/admin-app', adminAppRouter);
app.use('/admin-app/notifications', notificationsRouter);
app.use('/mobile-app/check-in', checkInRouter);
app.use('/mobile-app/workout', workoutRouter);
app.use('/mobile-app/profile', profileRouter);
app.use('/mobile-app/chat', chatRouter);
app.use('/admin-app/chat', chatRouter);
app.use('/mobile-app/notifications', notificationsRouter);
app.use('/mobile-app/exercises', exerciseRouter);
app.use('/mobile-app/calories', caloriesRouter);
app.post(
  '/webhook',
  bodyParser.raw({ type: 'application/json' }),
  (req, res) => {
    handleWebhook(req, res);
  }
);

import fs from 'fs';

import path from 'path';

import { handlePlanWebhook } from './webhook/plan_webhook';

const readHTMLFile = (filePath: string) => {
  return fs.readFileSync(filePath, 'utf8');
};

app.post(
  '/plan_webhook',
  bodyParser.raw({ type: 'application/json' }),

  async (req, res) => {
    handlePlanWebhook(req, res);
  }
);

const socketService = new SocketService(httpServer);
// Make socket service available to routes
app.set('socketService', socketService);
// Start server
httpServer.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`WebSocket server running at ws://localhost:${port}`);
});

app.get('/test', async (req, res) => {
  const template_path = path.join(
    '__dirname',
    '../',
    'templates',
    'training_plan.xlsx'
  );
});

export default app;
