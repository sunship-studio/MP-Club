import { upload } from "../../config/cloudinary";
import { ChatController } from "../../controllers/mobile/chat";

const express = require("express");


const chatRouter = express.Router();

chatRouter.post(
    '/upload-image', upload.single('file'), (req: any, res: any) => {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const { buffer, originalname, mimetype } = req.file;

        ChatController.uploadImage(buffer, originalname, mimetype)
            .then((result) => {
                res.status(200).json({ message: 'File uploaded successfully', data: result });
            })
            .catch((error) => {
                res.status(500).json({ error: error.message });
            });
    }
);


export default chatRouter;


