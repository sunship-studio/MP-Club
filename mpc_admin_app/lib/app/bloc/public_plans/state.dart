import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';

abstract class PublicPlansState extends Equatable {
  const PublicPlansState();

  @override
  List<Object?> get props => [];
}

class PublicPlansInitial extends PublicPlansState {}

class PublicPlansLoading extends PublicPlansState {}

class PublicPlansLoaded extends PublicPlansState {
  final List<PublicPlan> plans;

  const PublicPlansLoaded({required this.plans});

  @override
  List<Object?> get props => [plans];
}

class PublicPlansError extends PublicPlansState {
  final String message;

  const PublicPlansError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PublicPlanUploading extends PublicPlansState {}

class PublicPlanEditing extends PublicPlansState {
  final PublicPlan publicPlan;
  final DateTime lastUpdated;
  final List<Exercise>? exercisesDatabase;

  const PublicPlanEditing({
    required this.publicPlan,
    required this.lastUpdated,
    this.exercisesDatabase,
  });

  @override
  List<Object?> get props => [publicPlan, lastUpdated, exercisesDatabase];
}

class PublicPlanSearchingExercises extends PublicPlansState {
  final List<Exercise> exercises;
  final String query;

  const PublicPlanSearchingExercises({
    required this.exercises,
    required this.query,
  });

  @override
  List<Object?> get props => [exercises, query];
}
