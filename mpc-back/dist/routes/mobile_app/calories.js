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
const calories_1 = require("../../controllers/mobile/calories");
const caloriesRouter = express_1.default.Router();
caloriesRouter.post("/", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log("Calories log request body:", req.body);
        const { userId, calories, note } = req.body;
        const success = yield calories_1.CaloriesController.logCalories({ userId, calories, note });
        if (success) {
            res.json({ message: "Calories logged successfully" });
        }
        else {
            res.status(400).json({ message: "Logging calories failed" });
        }
    }
    catch (error) {
        console.error("Error during logging calories:", error);
        res.status(500).json({ message: "Error during logging calories" });
    }
}));
exports.default = caloriesRouter;
