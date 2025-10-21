import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/users/state.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersState());

  void loadUsers() async {
    emit(UsersLoadingState());
    Response response = await apiService.get('/online-users');
    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      List<User> currentSubscribers =
          (response.data as List).map((entry) => User.fromJson(entry)).toList();

      emit(UsersLoadedState(currentSubscribers: currentSubscribers));
    } else {
      emit(UsersErrorState('Failed to load current subscribers'));
    }
  }

  void saveCalorieGoal(String userId, int calories) async {
    emit(UsersLoadingState());
    Response response = await apiService.post('/user-calories', {
      'id': userId,
      'calories': calories,
    });
    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      loadUsers();
    } else {
      emit(UsersErrorState('Failed to save calorie goal'));
    }
  }

  void saveWeightGoal(String userId, double weight) async {
    emit(UsersLoadingState());
    Response response = await apiService.post('/user-target-weight', {
      'id': userId,
      'targetWeight': weight,
    });
    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      loadUsers();
    } else {
      emit(UsersErrorState('Failed to save weight goal'));
    }
  }
}
