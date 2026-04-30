import 'package:equatable/equatable.dart';
import 'package:mpc_admin_app/app/models/User.dart';

class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersLoadingState extends UsersState {
  @override
  List<Object?> get props => [];
}

class UsersLoadedState extends UsersState {
  final List<User> currentSubscribers;

  UsersLoadedState({this.currentSubscribers = const []});

  @override
  List<Object?> get props => [currentSubscribers];
}

class UsersErrorState extends UsersState {
  final String error;

  UsersErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
