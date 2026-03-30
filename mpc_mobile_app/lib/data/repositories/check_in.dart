import 'package:dio/dio.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';

class CheckInRepository {
  final DioClient dioClient;
  CheckInRepository(this.dioClient);
  Future<void> checkIn({
    required String userId,
    required double weight,
    String? note,
    String? imageUrl,
    String? wellbeing,
    List<String>? photos,
    String? biggestWin,
    String? struggles,
    String? questions,
  }) async {
    final response = await dioClient.post('/check-in', {
      'userId': userId,
      'weight': weight,
      'note': note,
      'imageUrl': imageUrl,
      'wellbeing': wellbeing,
      'photos': photos ?? [],
      'biggestWin': biggestWin,
      'struggles': struggles,
      'questions': questions,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to check in');
    }
  }

  Future<void> editCheckIn({
    required String checkInId,
    required double weight,
    required String userId,
    String? note,
  }) async {
    final response = await dioClient.put('/check-in/$checkInId', {
      'weight': weight,
      'note': note,
      'userId': userId,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to edit check-in');
    }
  }

  Future<String> uploadImage(String imagePath) async {
    final response = await dioClient.postFormData(
      endpoint: '/check-in/upload-image',
      formData: FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      }),
    );

    if (response.statusCode == 200) {
      return response.data['url'];
    }
    throw Exception('Failed to upload image');
  }
}
