"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cloudinary_1 = require("../../config/cloudinary");
const check_in_1 = require("../../controllers/mobile/check_in");
const checkInRouter = express_1.default.Router();
checkInRouter.post("/", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log("Check-in request body:", req.body);
        const { userId, weight, imageUrl, note } = req.body;
        const success = yield check_in_1.CheckInController.checkIn({ userId, weight, imageUrl, note });
        if (success) {
            res.json({ message: "Check-in successful" });
        }
        else {
            res.status(400).json({ message: "Check-in failed" });
        }
    }
    catch (error) {
        console.error("Error during check-in:", error);
        res.status(500).json({ message: "Error during check-in" });
    }
}));
checkInRouter.post("/upload-image", cloudinary_1.upload.single("file"), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    if (!req.file) {
        res.status(400).json({ message: "No file uploaded" });
        return;
    }
    const response = yield (0, cloudinary_1.uploadToCloudinary)(req.file.buffer, req.file.originalname);
    res.json(response);
}));
checkInRouter.put("/:id", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    console.log("Edit check-in request body:", req.body);
    yield check_in_1.CheckInController.editCheckIn(req, res);
}));
exports.default = checkInRouter;
