import { Request, Response } from 'express';
import { uploadToCloudinary } from '../../config/cloudinary';
import User from '../../models/User';

class ProfileController {
    public async uploadProfilePicture(req : Request, res: Response) {
        try {
            const userId = req.body.userId;
            if (!req.file) {

                return res.status(400).json({ message: 'No file uploaded' });
            }
            const result = await uploadToCloudinary(req.file.buffer, `profile_pictures/${userId}/${req.file.originalname}`);
            const user = await User.findById(userId);

            if (!user) {
                return res.status(404).json({ message: 'User not found' });
            }
            user.profilePictureUrl = result.url;
            await user.save();

            res.status(200).json({ message: 'Profile picture uploaded successfully', url: result.url });



         } catch (error) {
            console.error('Error uploading profile picture:', error);
            res.status(500).json({ message: 'Internal server error' });
        }

    }
}

export { ProfileController };
