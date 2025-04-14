import 'package:equatable/equatable.dart';
import 'package:mpc_mobile_app/app/models/CurrentSubcriber.dart';

class OnlineCoachingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnlineCoachingLoadingState extends OnlineCoachingState {
  @override
  List<Object?> get props => [];
}

class OnlineCoachingLoadedState extends OnlineCoachingState {
  final List<CurrentSubcriber> currentSubscribers;

  OnlineCoachingLoadedState({this.currentSubscribers = const []});

  @override
  List<Object?> get props => [currentSubscribers];
}


class OnlineCoachingErrorState extends OnlineCoachingState {
  final String error;

  OnlineCoachingErrorState(this.error);

  @override
  List<Object?> get props => [error];
}