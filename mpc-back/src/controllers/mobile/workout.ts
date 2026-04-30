import { Request, Response } from "express";
import User from "../../models/User";

type IncomingSet = {
  reps?: unknown;
  rir?: unknown;
  weight?: unknown;
  actualReps?: unknown;
};

type IncomingExercise = {
  exerciseId?: unknown;
  name?: unknown;
  videoUrl?: unknown;
  bodyParts?: unknown;
  minutes?: unknown;
  seconds?: unknown;
  sets?: unknown;
};

type IncomingWorkout = {
  date?: unknown;
  workout?: {
    name?: unknown;
    exercises?: unknown;
  };
};

function toNumberOrNull(v: unknown): number | null {
  if (v === null || v === undefined || v === "") return null;
  const n = typeof v === "number" ? v : Number(v);
  if (!Number.isFinite(n)) return null;
  if (n < 0) return null;
  return n;
}

function toIntOrZero(v: unknown): number {
  const n = toNumberOrNull(v);
  return n === null ? 0 : Math.round(n);
}

function sanitizeSet(raw: IncomingSet) {
  return {
    reps: raw.reps == null ? "0" : String(raw.reps),
    rir: toIntOrZero(raw.rir),
    weight: toIntOrZero(raw.weight),
    actualReps: toNumberOrNull(raw.actualReps),
  };
}

function sanitizeExercise(raw: IncomingExercise) {
  const sets = Array.isArray(raw.sets)
    ? raw.sets.map((s) => sanitizeSet(s as IncomingSet))
    : [];
  const bodyParts = Array.isArray(raw.bodyParts)
    ? raw.bodyParts.map((b) => String(b))
    : [];
  return {
    exerciseId: raw.exerciseId ? String(raw.exerciseId) : "",
    name: raw.name ? String(raw.name) : "",
    videoUrl: raw.videoUrl ? String(raw.videoUrl) : undefined,
    bodyParts,
    minutes: toIntOrZero(raw.minutes),
    seconds: toIntOrZero(raw.seconds),
    sets,
  };
}

function sanitizeWorkoutEntry(raw: IncomingWorkout) {
  let date: Date;
  if (raw.date) {
    const parsed = new Date(raw.date as string);
    date = isNaN(parsed.getTime()) ? new Date() : parsed;
  } else {
    date = new Date();
  }

  const inner = raw.workout ?? {};
  const exercises = Array.isArray(inner.exercises)
    ? inner.exercises.map((e) => sanitizeExercise(e as IncomingExercise))
    : [];

  return {
    date,
    workout: {
      name: inner.name ? String(inner.name) : "",
      exercises,
    },
  };
}

class WorkoutController {
  async logWorkout(req: Request, res: Response): Promise<void> {
    const { userId, workout } = req.body ?? {};

    if (!userId || typeof userId !== "string") {
      res.status(400).json({ success: false, error: "userId is required" });
      return;
    }
    if (!workout || typeof workout !== "object") {
      res.status(400).json({ success: false, error: "workout is required" });
      return;
    }

    try {
      const user = await User.findById(userId);
      if (!user) {
        res.status(404).json({ success: false, error: "User not found" });
        return;
      }

      const entry = sanitizeWorkoutEntry(workout as IncomingWorkout);

      if (!entry.workout.name || entry.workout.exercises.length === 0) {
        res.status(400).json({
          success: false,
          error: "workout must have a name and at least one exercise",
        });
        return;
      }

      user.doneWorkouts.push(entry as any);
      await user.save();

      const saved = user.doneWorkouts[user.doneWorkouts.length - 1];
      res.status(200).json({ success: true, entry: saved });
    } catch (error) {
      console.error("Error logging workout:", error);
      res.status(500).json({ success: false, error: "Server error" });
    }
  }
}

export default new WorkoutController();
