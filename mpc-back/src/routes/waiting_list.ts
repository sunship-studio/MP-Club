import express, {Request, Response} from 'express';
import WaitingListController from '../controllers/waiting_list';

// Waiting List Router
const waitingListRouter = express.Router();
const waitingListController = new WaitingListController();

// Add a new user to the waiting list
waitingListRouter.post('/add', waitingListController.addUserToWaitingList);



  





export default waitingListRouter;