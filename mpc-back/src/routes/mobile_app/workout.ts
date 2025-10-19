import express from "express";
const workoutController = require("../../controllers/mobile/workout");

const workoutRouter = express.Router();

workoutRouter.post("/log-workout", workoutController.logWorkout);


export default workoutRouter;
