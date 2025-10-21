import 'package:dio/dio.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/waiting_list/state.dart';
import 'package:mpc_admin_app/app/models/WaitingListEntry.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class WaitingListCubit extends Cubit<WaitingListState> {
  WaitingListCubit() : super(WaitingListState());
  void test() {
    print("Test function called");
  }

  void loadWaitingList() async {
    print("Loading waiting list...");
    Response response = await apiService.get('/waiting-list');
    if (response.statusCode == 200) {
      print(response.data);
      List<WaitingListEntry> waitingList =
          (response.data as List)
              .map((entry) => WaitingListEntry.fromJson(entry))
              .toList();
      emit(WaitinglistLoadedState(waitingList));
    } else {
      emit(WaitinglistErrorState('Failed to load waiting list'));
    }
  }

  void acceptEntry(String id) async {
    Response response = await apiService.post('/waiting-list/accept', {
      'id': id,
    });
    if (response.statusCode == 200) {
      loadWaitingList();
    } else {
      emit(WaitinglistErrorState('Failed to accept entry'));
    }
  }

  void rejectEntry(String id) async {
    Response response = await apiService.post('/waiting-list/reject', {
      'id': id,
    });
    if (response.statusCode == 200) {
      loadWaitingList();
    } else {
      emit(WaitinglistErrorState('Failed to reject entry'));
    }
  }

  void showError(String error) {
    emit(WaitinglistErrorState(error));
  }
}
