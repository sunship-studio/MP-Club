import { Request, Response } from 'express';
import Exercise from '../../models/Exercise';
import User from '../../models/User';

// Fisher-Yates shuffle algorithm for randomizing arrays
function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

class ExerciseController {
  static async searchExercises(req: Request, res: Response) {
    const query = req.query!.q as string;
    if (!query) {
      res.status(400).json({ error: 'Query parameter q is required' });
      return;
    }
    try {
      const exercises = await Exercise.find({
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { bodyParts: { $regex: query, $options: 'i' } },
        ],
        videoUrl: { $exists: true },
        videoLengthSeconds: { $exists: true },
      }).limit(20);
      res.status(200).json(exercises);
    } catch (error) {
      console.error('Error searching exercises:', error);
      res.status(500).json({ error: 'Failed to search exercises' });
    }
  }

  static async getTutorialsSection(req: Request, res: Response) {
    try {
      const userId = req.body.userId;
      if (!userId) {
        res.status(400).json({ error: 'User ID is required' });
        return;
      }
      const user = await User.findById(userId);
      if (!user) {
        res.status(404).json({ error: 'User not found' });
        return;
      }
      const allExercisesWithVideos = await Exercise.find({
        videoUrl: { $exists: true },
        videoLengthSeconds: { $exists: true },
      });

      // Randomize "For You" section
      let forYou;
      if (user.trainingPlan != null) {
        const matchingExercises = allExercisesWithVideos.filter((exercise) =>
          exercise.bodyParts.some((part) =>
            user.trainingPlan!.bodyParts.includes(part)
          )
        );
        forYou = shuffleArray(matchingExercises).slice(0, 4);
      } else {
        forYou = shuffleArray(allExercisesWithVideos).slice(0, 4);
      }

      // Get all unique body parts and randomize their order
      const allBodyPartsAvailable = Array.from(
        new Set(
          allExercisesWithVideos.flatMap((exercise) => exercise.bodyParts)
        )
      );

      const shuffledBodyParts = shuffleArray(allBodyPartsAvailable);

      // For each body part, get random exercises
      const byBodyPart = shuffledBodyParts.map((bodyPart) => {
        const exercisesForPart = allExercisesWithVideos.filter((exercise) =>
          exercise.bodyParts.includes(bodyPart)
        );
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
    } catch (error) {
      console.error('Error getting tutorials section:', error);
      res.status(500).json({ error: 'Failed to get tutorials section' });
    }
  }
  static categoryBodyParts: Record<string, string[]> = {
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

  static async searchByCategory(req: Request, res: Response) {
    const category = req.query.category as string;
    const allExercisesWithVideos = await Exercise.find({
      videoUrl: { $exists: true },
      videoLengthSeconds: { $exists: true },
    });

    if (!category || !(category in ExerciseController.categoryBodyParts)) {
      res.status(400).json({ error: 'Invalid or missing category' });
      return;
    }

    const bodyParts = ExerciseController.categoryBodyParts[category];
    const exercises = allExercisesWithVideos.filter((exercise) =>
      exercise.bodyParts.some((part) => bodyParts.includes(part))
    );

    res.status(200).json(exercises);
  }

  static async searchByVideoUrl(req: Request, res: Response) {
    const videoUrl = req.query.videoUrl as string;
    if (!videoUrl) {
      res.status(400).json({ error: 'Query parameter videoUrl is required' });
      return;
    }
    try {
      const exercise = await Exercise.findOne({
        videoUrl: videoUrl,
      });
      if (!exercise) {
        res.status(404).json({ error: 'Exercise not found' });
        return;
      }
      res.status(200).json(exercise);
    } catch (error) {
      console.error('Error searching exercise by video URL:', error);
      res.status(500).json({ error: 'Failed to search exercise by video URL' });
    }
  }
}

export { ExerciseController };
