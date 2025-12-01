import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/data/models/tutorial.dart';

class TutorialRepository {
  final DioClient dioClient;
  TutorialRepository({required this.dioClient});

  Future<List<Tutorial>> searchTutorials({required String query}) async {
    return [
      Tutorial(
        id: "1",
        title: 'Pull up',
        description: 'Tutorial on how to do pull ups effectively.',
        url: 'https://example.com/flutter-tutorial',
        bodyParts: ['Back', 'Biceps'],
        durationSeconds: 600,
      ),
      Tutorial(
        bodyParts: ['Chest'],
        id: "2",
        title: 'Cable Crossover',
        description: ' Learn the cable crossover exercise for chest muscles.',
        url: 'https://example.com/state-management-tutorial',
        durationSeconds: 900,
      ),
    ];
  }
}
