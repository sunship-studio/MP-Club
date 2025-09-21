import express from 'express';

import { Request, Response } from 'express';
import { storeAdminFCMToken } from '../services/notification';


const notificationsRouter = express.Router();

notificationsRouter.post(
    '/save_token',
    async (req: Request, res: Response) => {
        const { token, debug } = req.body;
        await storeAdminFCMToken(token, debug);
        res.status(200).json({ message: 'Token stored successfully' });
    }
);



export default notificationsRouter;