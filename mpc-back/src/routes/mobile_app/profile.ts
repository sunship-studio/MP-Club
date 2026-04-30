import express from "express";
import { upload } from "../../config/cloudinary";
import { ProfileController } from "../../controllers/mobile/profile";


const profileRouter = express.Router();

const profileController = new ProfileController();


profileRouter.post('/upload-profile-picture', upload.single('file'), async (req, res) => {
    await profileController.uploadProfilePicture(req, res);
});;


export default profileRouter;
