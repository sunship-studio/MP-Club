import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/repositories/check_in.dart';

class CheckInCubit extends Cubit<CheckInState> {
  final CheckInRepository checkInRepository;
  CheckInCubit(this.checkInRepository) : super(CheckInInitial());

  final List<String> _imagePaths = [];
  List<String> get imagePaths => List.unmodifiable(_imagePaths);

  void pickImage(String imagePath) {
    _imagePaths.add(imagePath);
    emit(CheckInImagesPicked(List.from(_imagePaths)));
  }

  void removeImage(int index) {
    _imagePaths.removeAt(index);
    emit(CheckInImagesPicked(List.from(_imagePaths)));
  }

  Future<void> submitCheckIn({
    required String userId,
    required String weight,
    String? note,
    String? wellbeing,
    String? biggestWin,
    String? struggles,
    String? questions,
  }) async {
    emit(CheckInLoading());
    try {
      if (weight.isEmpty) {
        throw ("Weight cannot be empty");
      } else if (double.tryParse(weight) == null) {
        throw ("Weight must be a valid number");
      }

      // Upload all images
      final List<String> photoUrls = [];
      for (final path in _imagePaths) {
        final url = await checkInRepository.uploadImage(path);
        photoUrls.add(url);
      }

      await checkInRepository.checkIn(
        userId: userId,
        weight: double.parse(weight),
        note: note,
        imageUrl: photoUrls.isNotEmpty ? photoUrls.first : null,
        wellbeing: wellbeing,
        photos: photoUrls,
        biggestWin: biggestWin,
        struggles: struggles,
        questions: questions,
      );
      _imagePaths.clear();
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

class CheckInImagesPicked extends CheckInState {
  final List<String> imagePaths;
  CheckInImagesPicked(this.imagePaths);
}
