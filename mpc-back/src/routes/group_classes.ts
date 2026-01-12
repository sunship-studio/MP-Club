import { Router } from 'express';
import GroupClassController from '../controllers/web/group_class_controller';

const groupClassRouter = Router();
const groupClassController = new GroupClassController();

groupClassRouter.get('/', async (req, res) => {
  await groupClassController.getGroupClasses(req, res);
});
export default groupClassRouter;
