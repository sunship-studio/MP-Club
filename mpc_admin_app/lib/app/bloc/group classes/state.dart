import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/group_class.dart';

class GroupClassesState extends Equatable {
  const GroupClassesState();

  @override
  List<Object?> get props => [];
}

class GroupClassesInitial extends GroupClassesState {}

class GroupClassesLoading extends GroupClassesState {}

class GroupClassesLoaded extends GroupClassesState {
  final List<GroupClass> groupClasses;

  const GroupClassesLoaded({required this.groupClasses});

  @override
  List<Object?> get props => [groupClasses];
}

class GroupClassesError extends GroupClassesState {
  final String message;

  const GroupClassesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroupClassEditing extends GroupClassesState {
  final GroupClass groupClass;

  const GroupClassEditing({required this.groupClass});

  @override
  List<Object?> get props => [groupClass];
}

class GroupClassViewingAttendees extends GroupClassesState {
  final GroupClass groupClass;

  const GroupClassViewingAttendees({required this.groupClass});

  @override
  List<Object?> get props => [groupClass];
}
