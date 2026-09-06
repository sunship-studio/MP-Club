import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/class_pass.dart';

class ClassPassesState extends Equatable {
  const ClassPassesState();

  @override
  List<Object?> get props => [];
}

class ClassPassesInitial extends ClassPassesState {}

class ClassPassesLoading extends ClassPassesState {}

class ClassPassesLoaded extends ClassPassesState {
  final List<ClassPass> passes;
  final List<ClassPassProduct> products;
  final String search;

  /// Set after an action so the screen can confirm what happened — a grant
  /// whose email did not send, or a link that went out.
  final String? notice;

  const ClassPassesLoaded({
    required this.passes,
    required this.products,
    this.search = '',
    this.notice,
  });

  @override
  List<Object?> get props => [passes, products, search, notice];
}

class ClassPassesError extends ClassPassesState {
  final String message;

  const ClassPassesError({required this.message});

  @override
  List<Object?> get props => [message];
}
