import { Request, Response } from "express";
import User from "../../models/User";

export class CheckInController {
    static async checkIn({userId, weight, imageUrl, note}: {userId: string, weight: number, imageUrl?: string, note?: string}): Promise<boolean> {
        const user = await User.findById(userId);
        if (!user) {
            return false;
        }
        console.log('data', {userId, weight, imageUrl, note});
        user.checkIns.push({

            date: new Date(),
            weight,
            imageUrl,
            note
        });

        await user.save();


        return true;
    }

    static async editCheckIn(req: Request, res: Response): Promise<boolean> {
        const { userId, weight, note } = req.body;
        const checkInId = req.params.id;
        try {
            const user = await User.findById(userId);
            if (!user) {
                res.status(404).json({ success: false, error: 'User not found' });
                return false;
            }
            const checkIn = user.checkIns.find(ci => (ci as any)._id.toString() === checkInId);
            if (!checkIn) {
                res.status(404).json({ success: false, error: 'Check-in not found' });
                return false;
            }

            checkIn.weight = weight;
            if (note) {
                checkIn.note = note;
            }

            await user.save();
            res.status(200).json({ success: true });
            return true;
        } catch (error) {
            res.status(500).json({ success: false, error: 'Error editing check-in' });
            console.error('Error editing check-in:', error);
            return false;
        }}
    }
