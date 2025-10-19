import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';

class TrainingPlanState extends Equatable {
  @override
  List<Object> get props => [];
}

class TrainingPlanInitial extends TrainingPlanState {}

class TrainingPlanEditing extends TrainingPlanState {
  final TrainingPlan trainingPlan;

  final List<Exercise> exercisesDatabase;

  DateTime lastUpdated;
  TrainingPlanEditing({
    required this.trainingPlan,
    required this.lastUpdated,

    this.exercisesDatabase = const [],
  });

  @override
  List<Object> get props => [trainingPlan, lastUpdated!];
}

class TrainingPlanSearchingExercises extends TrainingPlanState {
  final List<Exercise> exercises;
  final String query;

  TrainingPlanSearchingExercises({
    required this.exercises,
    required this.query,
  });

  @override
  List<Object> get props => [exercises, query];
} 


class TrainingPlanError extends TrainingPlanState {
  final String message;
  final TrainingPlan trainingPlan;

  TrainingPlanError({required this.message, required this.trainingPlan});

  @override
  List<Object> get props => [message, trainingPlan];
} 
