import { Router } from 'express';
import GroupClassController from '../controllers/web/group_class_controller';

const groupClassRouter = Router();
const groupClassController = new GroupClassController();

groupClassRouter.get('/', async (req, res) => {
  await groupClassController.getGroupClasses(req, res);
});

groupClassRouter.get('/passes', async (req, res) => {
  await groupClassController.getPassProducts(req, res);
});

groupClassRouter.get('/passes/mine', async (req, res) => {
  await groupClassController.getMyPass(req, res);
});

groupClassRouter.post('/passes/create-checkout-session', async (req, res) => {
  await groupClassController.createPassCheckoutSession(req, res);
});

groupClassRouter.get('/my-bookings', async (req, res) => {
  await groupClassController.getMyBookings(req, res);
});

groupClassRouter.post('/passes/auto-renew', async (req, res) => {
  await groupClassController.setAutoRenew(req, res);
});

groupClassRouter.post('/book-with-pass', async (req, res) => {
  await groupClassController.bookWithPass(req, res);
});

groupClassRouter.post('/cancel-with-pass', async (req, res) => {
  await groupClassController.cancelPassBooking(req, res);
});

groupClassRouter.post('/create-checkout-session', async (req, res) => {
  await groupClassController.createCheckoutSession(req, res);
});

export default groupClassRouter;
export { groupClassController };
