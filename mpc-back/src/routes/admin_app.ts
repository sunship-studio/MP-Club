import express, { Request, Response } from 'express';
import multer from 'multer';

import AdminAppController from '../controllers/admin/admin_app';
import { adminAppAuth } from '../middleware/auth';

// Mobile App Router
const adminAppRouter = express.Router();
const adminAppController = new AdminAppController();

// Multer memory storage for file uploads
const storage = multer.memoryStorage();
const uploadFields = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB max
}).fields([
  { name: 'video', maxCount: 1 },
  { name: 'image', maxCount: 1 },
]);

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
    await adminAppController.addPlanForSell(req, res);
  }
);

adminAppRouter.get(
  '/training-plans',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getTrainingPlans(req, res);
  }
);

adminAppRouter.get(
  '/group-classes',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.getGroupClasses(req, res);
  }
);

adminAppRouter.post(
  '/add-group-class',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.createGroupClass(req, res);
  }
);

adminAppRouter.post(
  '/edit-group-class',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.editGroupClass(req, res);
  }
);

adminAppRouter.post(
  '/delete-group-class',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.deleteGroupClass(req, res);
  }
);

// ============ EXERCISE CRUD ROUTES ============

adminAppRouter.post(
  '/create-exercise',
  adminAppAuth,
  uploadFields,
  async (req: Request, res: Response) => {
    await adminAppController.createExercise(req, res);
  }
);

adminAppRouter.post(
  '/update-exercise',
  adminAppAuth,
  uploadFields,
  async (req: Request, res: Response) => {
    await adminAppController.updateExercise(req, res);
  }
);

adminAppRouter.post(
  '/delete-exercise',
  adminAppAuth,
  async (req: Request, res: Response) => {
    await adminAppController.deleteExercise(req, res);
  }
);

export default adminAppRouter;
