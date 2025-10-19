"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const cloudinary_1 = require("../../config/cloudinary");
const chat_1 = require("../../controllers/mobile/chat");
const express = require("express");
const chatRouter = express.Router();
chatRouter.post('/upload-image', cloudinary_1.upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }
    const { buffer, originalname, mimetype } = req.file;
    chat_1.ChatController.uploadImage(buffer, originalname, mimetype)
        .then((result) => {
        res.status(200).json({ message: 'File uploaded successfully', data: result });
    })
        .catch((error) => {
        res.status(500).json({ error: error.message });
    });
});
exports.default = chatRouter;
