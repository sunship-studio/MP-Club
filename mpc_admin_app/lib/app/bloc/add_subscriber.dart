import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class AddSubscribeCubit extends Cubit<AddSubscriberState> {
  AddSubscribeCubit() : super(AddSubscriberState());

  void addSubscriber({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    emit(AddSubscriberLoading());
    try {
      await ApiService().post('/add-subscriber', {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
      });
      emit(AddSubscriberSuccess());
    } catch (e) {
      emit(AddSubscriberFailure(e.toString()));
    }
  }
}

class AddSubscriberState {}

class AddSubscriberInitial extends AddSubscriberState {}

class AddSubscriberLoading extends AddSubscriberState {}

class AddSubscriberSuccess extends AddSubscriberState {}

class AddSubscriberFailure extends AddSubscriberState {
  final String error;

  AddSubscriberFailure(this.error);
}
