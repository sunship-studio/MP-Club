import 'package:mpc_mobile_app/data/models/UserExercise.dart';

class TrainingDay {
  String name;
  List<UserExercise> exercises;

  TrainingDay({this.name = "", required this.exercises});

  static String _toStringOrEmpty(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'];

    return TrainingDay(
      name: _toStringOrEmpty(json['name']),
      exercises:
          (exercisesJson is List)
              ? exercisesJson
                  .whereType<Map>()
                  .map(
                    (e) => UserExercise.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  TrainingDay deepCopy() {
    return TrainingDay(
      name: name,
      exercises: exercises.map((e) => e.deepCopy()).toList(),
    );
  }
}
