import 'dart:convert';

import 'package:mpc_mobile_app/data/models/TrainingDay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutWeightPrefsRepository {
  WorkoutWeightPrefsRepository({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  String _storageKey(String userId, String trainingPlanName) {
    return 'workout_weight_overrides_${userId}_${Uri.encodeComponent(trainingPlanName)}';
  }

  Future<Map<String, dynamic>> getOverrides({
    required String userId,
    required String trainingPlanName,
  }) async {
    final raw = sharedPreferences.getString(
      _storageKey(userId, trainingPlanName),
    );
    if (raw == null || raw.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> setWeight({
    required String userId,
    required String trainingPlanName,
    required int dayIndex,
    required String exerciseKey,
    required int setIndex,
    required int weight,
  }) async {
    final data = await getOverrides(
      userId: userId,
      trainingPlanName: trainingPlanName,
    );

    final dayKey = dayIndex.toString();
    final dayData = (data[dayKey] as Map?)?.cast<String, dynamic>() ?? {};
    final exerciseData =
        (dayData[exerciseKey] as Map?)?.cast<String, dynamic>() ?? {};

    exerciseData[setIndex.toString()] = weight;
    dayData[exerciseKey] = exerciseData;
    data[dayKey] = dayData;

    await sharedPreferences.setString(
      _storageKey(userId, trainingPlanName),
      jsonEncode(data),
    );
  }

  Future<void> saveTrainingDay({
    required String userId,
    required String trainingPlanName,
    required int dayIndex,
    required TrainingDay day,
    required String Function(int exerciseIndex) exerciseKeyBuilder,
  }) async {
    for (
      var exerciseIndex = 0;
      exerciseIndex < day.exercises.length;
      exerciseIndex++
    ) {
      final sets = day.exercises[exerciseIndex].sets;
      if (sets == null || sets.isEmpty) {
        continue;
      }

      for (var setIndex = 0; setIndex < sets.length; setIndex++) {
        await setWeight(
          userId: userId,
          trainingPlanName: trainingPlanName,
          dayIndex: dayIndex,
          exerciseKey: exerciseKeyBuilder(exerciseIndex),
          setIndex: setIndex,
          weight: sets[setIndex].weight,
        );
      }
    }
  }
}
