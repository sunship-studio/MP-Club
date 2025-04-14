import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/app/bloc/online_coaching/state.dart';
import 'package:mpc_mobile_app/app/models/CurrentSubcriber.dart';
import 'package:mpc_mobile_app/app/network/api.dart';

class OnlineCoachingCubit extends Cubit<OnlineCoachingState> {
  OnlineCoachingCubit() : super(OnlineCoachingState());

  void loadCurrentSubscribers() async {
    emit(OnlineCoachingLoadingState());
    Response response = await apiService.get(
      '/mobile-app/online-subscriptions',
    );
    if (response.statusCode == 200) {
      List<CurrentSubcriber> currentSubscribers =
          (response.data as List)
              .map((entry) => CurrentSubcriber.fromJson(entry))
              .toList();
      emit(OnlineCoachingLoadedState(currentSubscribers: currentSubscribers));
    } else {
      emit(OnlineCoachingErrorState('Failed to load current subscribers'));
    }
  }
}
