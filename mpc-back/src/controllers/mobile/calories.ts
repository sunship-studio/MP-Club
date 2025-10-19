import User from "../../models/User";

class CaloriesController {
    static async logCalories({userId, calories, note}: {userId: string, calories: number, note?: string}): Promise<boolean> {
        const user = await User.findById(userId);
        if (!user) {
            return false;
        }

        user.caloriesLogs.push({
            date: new Date(),
            calories,
            note
        });

        await user.save();

        return true;
    }
}
export { CaloriesController };
