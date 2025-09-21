import Exercise from "../models/Exercise";

export class ExerciseService {
  static async search(query: string) {
    const exercises = await Exercise.find({
      name: { $regex: query, $options: "i" },
    });
    return exercises;
  }

  static async initialLoad() {
    const exercises = await Exercise.find().limit(10);
    return exercises;
  }

  static async getById(exerciseId: string) {
    const exercise = await Exercise.findById(exerciseId);
    return exercise;
  }

  static async load(limit = 20, offset = 10) {
    const exercises = await Exercise.find().skip(offset).limit(limit);
    return exercises;
  }
}
