import { Router } from 'express';
import { ExerciseController } from '../../controllers/mobile/exercise';
import { verifyToken } from '../../middleware/auth';
const exerciseRouter = Router();

exerciseRouter.get('/search', verifyToken, async (req, res) => {
  await ExerciseController.searchExercises(req, res);
});

exerciseRouter.post('/tutorials-section', verifyToken, async (req, res) => {
  await ExerciseController.getTutorialsSection(req, res);
});

exerciseRouter.get('/search-by-category', verifyToken, async (req, res) => {
  await ExerciseController.searchByCategory(req, res);
});

exerciseRouter.get('/search-video-url', verifyToken, async (req, res) => {
  await ExerciseController.searchByVideoUrl(req, res);
});

export { exerciseRouter };
