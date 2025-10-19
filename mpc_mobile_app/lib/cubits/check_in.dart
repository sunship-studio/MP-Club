import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/repositories/check_in.dart';

class CheckInCubit extends Cubit<CheckInState> {
  final CheckInRepository checkInRepository;
  CheckInCubit(this.checkInRepository) : super(CheckInInitial());

  void pickImage(String imagePath) {
    emit(CheckInImagePicked(imagePath));
  }

  Future<void> submitCheckIn({
    required String userId,
    required String weight,
    String? note,
    String? imagePath,
  }) async {
    emit(CheckInLoading());
    String? imageUrl;
    try {
      if (weight.isEmpty) {
        throw ("Weight cannot be empty");
      } else if (double.tryParse(weight) == null) {
        throw ("Weight must be a valid number");
      }
      if (imagePath != null) {
        imageUrl = await checkInRepository.uploadImage(imagePath);
      }
      await checkInRepository.checkIn(
        userId: userId,
        weight: double.parse(weight),
        note: note,
        imageUrl: imageUrl,
      );
      emit(CheckInSuccess());
    } catch (e) {
      emit(CheckInError("$e"));
      throw Exception("Failed to submit check-in: $e");
    }
  }

  Future<void> editCheckIn({
    required String checkInId,
    required String weight,
    required String userId,
    String? note,
  }) async {
    emit(CheckInLoading());
    try {
      if (weight.isEmpty) {
        throw ("Weight cannot be empty");
      } else if (double.tryParse(weight) == null) {
        throw ("Weight must be a valid number");
      }
      await checkInRepository.editCheckIn(
        userId: userId,
        checkInId: checkInId,
        weight: double.parse(weight),
        note: note,
      );
      emit(CheckInSuccess());
    } catch (e) {
      emit(CheckInError("$e"));
      throw Exception("Failed to edit check-in: $e");
    }
  }
}

class CheckInState {}

class CheckInInitial extends CheckInState {}

class CheckInLoading extends CheckInState {}

class CheckInSuccess extends CheckInState {}

class CheckInError extends CheckInState {
  final String message;
  CheckInError(this.message);
}

class CheckInImagePicked extends CheckInState {
  final String imagePath;
  CheckInImagePicked(this.imagePath);
}
