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
exports.ExerciseController = void 0;
const Exercise_1 = __importDefault(require("../../models/Exercise"));
const User_1 = __importDefault(require("../../models/User"));
// Fisher-Yates shuffle algorithm for randomizing arrays
function shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}
class ExerciseController {
    static searchExercises(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const query = req.query.q;
            if (!query) {
                res.status(400).json({ error: 'Query parameter q is required' });
                return;
            }
            try {
                const exercises = yield Exercise_1.default.find({
                    $or: [
                        { name: { $regex: query, $options: 'i' } },
                        { bodyParts: { $regex: query, $options: 'i' } },
                    ],
                    videoUrl: { $exists: true },
                    videoLengthSeconds: { $exists: true },
                }).limit(20);
                res.status(200).json(exercises);
            }
            catch (error) {
                console.error('Error searching exercises:', error);
                res.status(500).json({ error: 'Failed to search exercises' });
            }
        });
    }
    static getTutorialsSection(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const userId = req.body.userId;
                if (!userId) {
                    res.status(400).json({ error: 'User ID is required' });
                    return;
                }
                const user = yield User_1.default.findById(userId);
                if (!user) {
                    res.status(404).json({ error: 'User not found' });
                    return;
                }
                const allExercisesWithVideos = yield Exercise_1.default.find({
                    videoUrl: { $exists: true },
                    videoLengthSeconds: { $exists: true },
                });
                // Randomize "For You" section
                let forYou;
                if (user.trainingPlan != null) {
                    const matchingExercises = allExercisesWithVideos.filter((exercise) => exercise.bodyParts.some((part) => user.trainingPlan.bodyParts.includes(part)));
                    forYou = shuffleArray(matchingExercises).slice(0, 4);
                }
                else {
                    forYou = shuffleArray(allExercisesWithVideos).slice(0, 4);
                }
                // Get all unique body parts and randomize their order
                const allBodyPartsAvailable = Array.from(new Set(allExercisesWithVideos.flatMap((exercise) => exercise.bodyParts)));
                const shuffledBodyParts = shuffleArray(allBodyPartsAvailable);
                // For each body part, get random exercises
                const byBodyPart = shuffledBodyParts.map((bodyPart) => {
                    const exercisesForPart = allExercisesWithVideos.filter((exercise) => exercise.bodyParts.includes(bodyPart));
                    return {
                        bodyPart,
                        exercises: shuffleArray(exercisesForPart).slice(0, 4),
                    };
                });
                console.log('Retrieved tutorials section for user:', userId);
                console.log('For You section:', forYou);
                console.log('By Body Part section:', byBodyPart);
                res.status(200).json({
                    forYou: forYou,
                    byBodyPart: byBodyPart,
                });
            }
            catch (error) {
                console.error('Error getting tutorials section:', error);
                res.status(500).json({ error: 'Failed to get tutorials section' });
            }
        });
    }
    static searchByCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const category = req.query.category;
            const allExercisesWithVideos = yield Exercise_1.default.find({
                videoUrl: { $exists: true },
                videoLengthSeconds: { $exists: true },
            });
            if (!category || !(category in ExerciseController.categoryBodyParts)) {
                res.status(400).json({ error: 'Invalid or missing category' });
                return;
            }
            const bodyParts = ExerciseController.categoryBodyParts[category];
            const exercises = allExercisesWithVideos.filter((exercise) => exercise.bodyParts.some((part) => bodyParts.includes(part)));
            res.status(200).json(exercises);
        });
    }
    static searchByVideoUrl(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const videoUrl = req.query.videoUrl;
            if (!videoUrl) {
                res.status(400).json({ error: 'Query parameter videoUrl is required' });
                return;
            }
            try {
                const exercise = yield Exercise_1.default.findOne({
                    videoUrl: videoUrl,
                });
                if (!exercise) {
                    res.status(404).json({ error: 'Exercise not found' });
                    return;
                }
                res.status(200).json(exercise);
            }
            catch (error) {
                console.error('Error searching exercise by video URL:', error);
                res.status(500).json({ error: 'Failed to search exercise by video URL' });
            }
        });
    }
}
exports.ExerciseController = ExerciseController;
ExerciseController.categoryBodyParts = {
    'Lower Body': [
        'Quadriceps',
        'Glutes',
        'Hamstrings',
        'Calves',
        'Abductors',
        'Adductors',
    ],
    'Upper Body': [
        'Chest',
        'Upper Chest',
        'Back',
        'Lats',
        'Shoulders',
        'Rear Delts',
        'Traps',
        'Lower Back',
    ],
    Arms: ['Biceps', 'Triceps'],
    Core: ['Core'],
};
