import { Router } from 'express';
import GroupClassController from '../controllers/web/group_class_controller';

const groupClassRouter = Router();
const groupClassController = new GroupClassController();

groupClassRouter.get('/', async (req, res) => {
  await groupClassController.getGroupClasses(req, res);
});

groupClassRouter.post('/book', async (req, res) => {
  await groupClassController.bookGroupClass(req, res);
});
export default groupClassRouter;
