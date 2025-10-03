import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';

class TrainingPlanState extends Equatable {
  @override
  List<Object> get props => [];
}

class TrainingPlanInitial extends TrainingPlanState {}

class TrainingPlanEditing extends TrainingPlanState {
  final TrainingPlan trainingPlan;
  DateTime lastUpdated;
  TrainingPlanEditing({required this.trainingPlan, required this.lastUpdated});

  @override
  List<Object> get props => [trainingPlan, lastUpdated!];
}
