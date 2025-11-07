import express from 'express';

import { Request, Response } from 'express';
import { verifyToken } from '../middleware/auth';
import {
  removeAdminFCMToken,
  removeUserFCMToken,
  storeAdminFCMToken,
  storeUserFCMToken,
} from '../services/notification';

const notificationsRouter = express.Router();

// ========================================
// ADMIN (SHANE) ENDPOINTS
// ========================================

// Admin FCM token registration
notificationsRouter.post(
  '/save_token',
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { token, debug } = req.body;

      if (!token) {
        res.status(400).json({ error: 'Token is required' });
        return;
      }

      await storeAdminFCMToken(token, debug || false);
      res.status(200).json({
        message: 'Admin token stored successfully',
        success: true,
      });
    } catch (error: any) {
      console.error('Error storing admin FCM token:', error);
      res.status(500).json({
        error: 'Failed to store admin token',
        message: error.message,
      });
    }
  }
);

// Admin FCM token removal (on Shane's logout)
notificationsRouter.post(
  '/remove_admin_token',
  async (req: Request, res: Response): Promise<void> => {
    try {
      await removeAdminFCMToken();
      res.status(200).json({
        message: 'Admin token removed successfully',
        success: true,
      });
    } catch (error: any) {
      console.error('Error removing admin FCM token:', error);
      res.status(500).json({
        error: 'Failed to remove admin token',
        message: error.message,
      });
    }
  }
);

// ========================================
// USER (CLIENT) ENDPOINTS
// ========================================

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
