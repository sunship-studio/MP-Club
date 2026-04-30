import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/models/workout.dart';
import 'package:mpc_mobile_app/data/repositories/workout.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepository workoutRepository;

  WorkoutCubit({required this.workoutRepository}) : super(WorkoutInitial());

  Future<void> logWorkout(Workout workout, String userId) async {
    emit(WorkoutLoading());
    try {
      final success = await workoutRepository.logWorkout(
        workout: workout,
        userId: userId,
      );
      if (success) {
        emit(WorkoutLogged());
      } else {
        emit(WorkoutError('Failed to log workout'));
      }
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }
}

abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLogged extends WorkoutState {}

class WorkoutError extends WorkoutState {
  final String message;

  WorkoutError(this.message);
}
