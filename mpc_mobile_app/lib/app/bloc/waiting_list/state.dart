import 'package:equatable/equatable.dart';
import 'package:mpc_mobile_app/app/models/WaitingListEntry.dart';

class WaitingListState extends Equatable {
  WaitingListState();

  @override
  List<Object?> get props => [];
}

class WaitingListLoadingState extends WaitingListState {
  WaitingListLoadingState();

  @override
  List<Object?> get props => [];
}

class WaitinglistLoadedState extends WaitingListState {
  final List<WaitingListEntry> waitingList;

  WaitinglistLoadedState(this.waitingList);

  @override
  List<Object?> get props => [waitingList];
}

class WaitinglistErrorState extends WaitingListState {
  final String error;

  WaitinglistErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
