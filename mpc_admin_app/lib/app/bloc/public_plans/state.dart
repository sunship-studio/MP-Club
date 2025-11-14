import 'package:equatable/equatable.dart';
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
