import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';
import 'package:mpc_mobile_app/data/models/tutorials_section.dart';

class ExerciseRepository {
  final DioClient dioClient;
  ExerciseRepository({required this.dioClient});

  Future<List<Exercise>> searchExercises({required String query}) async {
    final response = await dioClient.get(
      endpoint: '/exercises/search',
      queryParameters: {'q': query},
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<TutorialsSection> getTutorialsSection({required String userId}) async {
    final response = await dioClient.post('/exercises/tutorials-section', {
      'userId': userId,
    });

    return TutorialsSection.fromJson(response.data);
  }

  Future<List<Exercise>> searchByCategory({required String category}) async {
    final response = await dioClient.get(
      endpoint: '/exercises/search-by-category',
      queryParameters: {'category': category},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<Exercise?> fetchExerciseByVideoUrl({required String videoUrl}) async {
    final response = await dioClient.get(
      endpoint: '/exercises/search-video-url',
      queryParameters: {'videoUrl': videoUrl},
    );

    if (response.statusCode == 200 && response.data != null) {
      return Exercise.fromJson(response.data);
    }
    return null;
  }
}
