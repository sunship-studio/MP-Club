import express from "express";
import workoutController from "../../controllers/mobile/workout";

const workoutRouter = express.Router();

workoutRouter.post(
  "/log-workout",
  workoutController.logWorkout.bind(workoutController),
);

export default workoutRouter;
