import express from "express";
import { CaloriesController } from "../../controllers/mobile/calories";
const caloriesRouter = express.Router();

caloriesRouter.post("/", async (req, res) => {
    try {
        console.log("Calories log request body:", req.body);
        const { userId, calories, note } = req.body;
        const success = await CaloriesController.logCalories({ userId, calories, note });
        if (success) {
            res.json({ message: "Calories logged successfully" });
        } else {
            res.status(400).json({ message: "Logging calories failed" });

        }
    }
    catch (error) {
        console.error("Error during logging calories:", error);
        res.status(500).json({ message: "Error during logging calories" });

    }
}
);


export default caloriesRouter;
