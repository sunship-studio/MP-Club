import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';

abstract class ExercisesState extends Equatable {
  const ExercisesState();

  @override
  List<Object?> get props => [];
}

class ExercisesInitial extends ExercisesState {}

class ExercisesLoading extends ExercisesState {}

class ExercisesLoaded extends ExercisesState {
  final List<Exercise> exercises;
  final List<Exercise> filteredExercises;
  final String searchQuery;
  final String? selectedBodyPart;

  const ExercisesLoaded({
    required this.exercises,
    required this.filteredExercises,
    this.searchQuery = '',
    this.selectedBodyPart,
  });

  @override
  List<Object?> get props => [
    exercises,
    filteredExercises,
    searchQuery,
    selectedBodyPart,
  ];

  ExercisesLoaded copyWith({
    List<Exercise>? exercises,
    List<Exercise>? filteredExercises,
    String? searchQuery,
    String? selectedBodyPart,
  }) {
    return ExercisesLoaded(
      exercises: exercises ?? this.exercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBodyPart: selectedBodyPart,
    );
  }
}

class ExercisesError extends ExercisesState {
  final String message;

  const ExercisesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ExerciseSaving extends ExercisesState {
  final double? uploadProgress;

  const ExerciseSaving({this.uploadProgress});

  @override
  List<Object?> get props => [uploadProgress];
}

class ExerciseSaved extends ExercisesState {
  final String message;

  const ExerciseSaved({required this.message});

  @override
  List<Object?> get props => [message];
}
