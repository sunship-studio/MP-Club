import 'package:flutter/cupertino.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/data/models/workout.dart';

class WorkoutRepository {
  DioClient dio;

  WorkoutRepository({required this.dio});

  Future<bool> logWorkout({
    required Workout workout,
    required String userId,
  }) async {
    try {
      final response = await dio.post('/workout/log-workout', {
        'userId': userId,
        'workout': workout.toJson(),
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error logging workout: $e');
      throw ('Failed due to server error: $e');
    }
  }
}
