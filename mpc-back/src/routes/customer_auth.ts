import { Router } from 'express';

import AuthController from '../controllers/web/auth';

const customerAuthRouter = Router();
const authController = new AuthController();

customerAuthRouter.post('/request-link', async (req, res) => {
  await authController.requestSignInLink(req, res);
});

customerAuthRouter.post('/verify', async (req, res) => {
  await authController.verifySignInLink(req, res);
});

customerAuthRouter.get('/me', async (req, res) => {
  await authController.getCurrentCustomer(req, res);
});

customerAuthRouter.post('/sign-out', async (req, res) => {
  await authController.signOut(req, res);
});

export default customerAuthRouter;
