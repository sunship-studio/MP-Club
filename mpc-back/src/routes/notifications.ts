import express from 'express';

import { Request, Response } from 'express';
import { verifyToken } from '../middleware/auth';
import {
  removeUserFCMToken,
  storeAdminFCMToken,
  storeUserFCMToken,
} from '../services/notification';

const notificationsRouter = express.Router();

// Admin FCM token registration
notificationsRouter.post('/save_token', async (req: Request, res: Response) => {
  const { token, debug } = req.body;
  await storeAdminFCMToken(token, debug);
  res.status(200).json({ message: 'Token stored successfully' });
});

// User FCM token registration (protected route)
notificationsRouter.post(
  '/register-token',
  verifyToken,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { fcmToken } = req.body;
      const userId = req.user?.id;

      if (!userId) {
        res.status(401).json({ error: 'User not authenticated' });
        return;
      }

      if (!fcmToken) {
        res.status(400).json({ error: 'FCM token is required' });
        return;
      }

      await storeUserFCMToken(userId, fcmToken);
      res.status(200).json({
        message: 'FCM token registered successfully',
        success: true,
      });
    } catch (error: any) {
      console.error('Error registering FCM token:', error);
      res.status(500).json({
        error: 'Failed to register FCM token',
        message: error.message,
      });
    }
  }
);

// Remove user FCM token (on logout)
notificationsRouter.post(
  '/remove-token',
  verifyToken,
  async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        res.status(401).json({ error: 'User not authenticated' });
        return;
      }

      await removeUserFCMToken(userId);
      res.status(200).json({
        message: 'FCM token removed successfully',
        success: true,
      });
    } catch (error: any) {
      console.error('Error removing FCM token:', error);
      res.status(500).json({
        error: 'Failed to remove FCM token',
        message: error.message,
      });
    }
  }
);

export default notificationsRouter;
