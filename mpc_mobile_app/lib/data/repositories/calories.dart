import 'package:flutter/material.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';

class CaloriesRepository {
  DioClient dio;
  CaloriesRepository({required this.dio});

  Future<bool> logCalories({
    required String userId,
    required int calories,
    String? note,
  }) async {
    try {
      final response = await dio.post('/calories', {
        'userId': userId,
        'calories': calories,
        'note': note,
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error logging calories: $e');
      throw ('Failed to log calories: $e');
    }
  }
}
