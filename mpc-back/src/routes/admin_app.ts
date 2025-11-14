import express, { Request, Response } from 'express';

import { uploadExcel } from '../config/cloudinary';
import AdminAppController from '../controllers/admin/admin_app';
import { adminAppAuth } from '../middleware/auth';

// Mobile App Router
const adminAppRouter = express.Router();
const adminAppController = new AdminAppController();

// Route to get the waiting list
adminAppRouter.get(
  '/waiting-list',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getWaitingList(req, res);
  }
);

adminAppRouter.get('/exercises', async (req: Request, res: Response) => {
  await adminAppController.getAllExercises(req, res);
});

// Route to get online subscriptions
adminAppRouter.get(
  '/online-users',

  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getOnlineCoachingUsers(req, res);
  }
);

adminAppRouter.post(
  '/waiting-list/reject',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.rejectWaitingList(req, res);
  }
);

adminAppRouter.post(
  '/waiting-list/accept',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.acceptWaitingList(req, res);
  }
);

adminAppRouter.post(
  '/user-calories',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to save user calories:', req.body);
    await adminAppController.saveUserCalories(req, res);
  }
);

adminAppRouter.post(
  '/user-target-weight',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to save user target weight:', req.body);
    await adminAppController.saveUserTargetWeight(req, res);
  }
);

adminAppRouter.post(
  '/save-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to save training plan:', req.body);
    await adminAppController.saveTrainingPlan(req, res);
  }
);

adminAppRouter.post(
  '/add-subscriber',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to add subscriber:', req.body);
    await adminAppController.addSubscriber(req, res);
  }
);

adminAppRouter.post(
  '/load-exercises',
  async (req: Request, res: Response) => {}
);

adminAppRouter.post(
  '/edit-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to edit training plan:', req.body);
    await adminAppController.editTrainingPlan(req, res);
  }
);

adminAppRouter.post(
  '/delete-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to delete training plan:', req.body);
    await adminAppController.deleteTrainingPlan(req, res);
  }
);

// add training plan to sell on website

adminAppRouter.post(
  '/add-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to add training plan to sell:', req.body);
    await adminAppController.addTrainingPlanToSell(req, res);
  }
);

adminAppRouter.get(
  '/training-plans',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getTrainingPlans(req, res);
  }
);

adminAppRouter.post(
  '/upload-training-plan-file',
  uploadExcel.single('file'),
  async (req: Request, res: Response) => {
    await adminAppController.uploadTrainingPlanFile(req, res);
  }
);
export default adminAppRouter;
