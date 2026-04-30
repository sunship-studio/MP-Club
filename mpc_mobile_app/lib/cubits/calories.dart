import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/repositories/calories.dart';

class CaloriesCubit extends Cubit<CaloriesState> {
  CaloriesCubit({required this.caloriesRepository}) : super(CaloriesInitial());
  CaloriesRepository caloriesRepository;

  void logCalories(String calories, String? note, String userId) async {
    emit(CaloriesLoading());
    try {
      if (calories.isEmpty) {
        throw ('Calories field cannot be empty');
      } else if (int.tryParse(calories) == null) {
        throw ('Calories must be a valid number');
      }

      final success = await caloriesRepository.logCalories(
        userId: userId,
        calories: int.parse(calories),
        note: note,
      );
      if (success) {
        emit(CaloriesSuccess());
      } else {
        throw Exception('Logging calories failed due to server error');
      }
    } catch (e) {
      debugPrint('Error logging calories: $e');
      emit(CaloriesError('$e'));
    }
  }

  // Add your cubit methods and logic here
}

class CaloriesState {}

class CaloriesInitial extends CaloriesState {}

class CaloriesLoading extends CaloriesState {}

class CaloriesSuccess extends CaloriesState {}

class CaloriesError extends CaloriesState {
  final String message;
  CaloriesError(this.message);
}
