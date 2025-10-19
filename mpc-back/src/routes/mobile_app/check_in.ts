import express from "express";
import { upload, uploadToCloudinary } from "../../config/cloudinary";
import { CheckInController } from "../../controllers/mobile/check_in";

const checkInRouter = express.Router();

checkInRouter.post("/", async (req, res) => {
  try {
    console.log("Check-in request body:", req.body);
    const { userId, weight, imageUrl, note } = req.body;
    const success = await CheckInController.checkIn({ userId, weight, imageUrl, note });
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
});

checkInRouter.post("/upload-image", upload.single("file"), async (req, res) => {
    if (!req.file) {
        res.status(400).json({ message: "No file uploaded" });
        return;
    }
    const response = await uploadToCloudinary(req.file.buffer, req.file.originalname);

    res.json(response);

});

checkInRouter.put("/:id", async (req, res) => {
    console.log("Edit check-in request body:", req.body);
    await CheckInController.editCheckIn(req, res);
});

export default checkInRouter;
