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
Object.defineProperty(exports, "__esModule", { value: true });
exports.exerciseRouter = void 0;
const express_1 = require("express");
const exercise_1 = require("../../controllers/mobile/exercise");
const auth_1 = require("../../middleware/auth");
const exerciseRouter = (0, express_1.Router)();
exports.exerciseRouter = exerciseRouter;
exerciseRouter.get('/search', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield exercise_1.ExerciseController.searchExercises(req, res);
}));
exerciseRouter.post('/tutorials-section', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield exercise_1.ExerciseController.getTutorialsSection(req, res);
}));
exerciseRouter.get('/search-by-category', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield exercise_1.ExerciseController.searchByCategory(req, res);
}));
exerciseRouter.get('/search-video-url', auth_1.verifyToken, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield exercise_1.ExerciseController.searchByVideoUrl(req, res);
}));
