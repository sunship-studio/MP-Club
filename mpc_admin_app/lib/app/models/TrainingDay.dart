import 'package:mpc_admin_app/app/models/Exercise.dart';

class TrainingDay {
  String name;
  List<Exercise> exercises;

  TrainingDay({this.name = "", required this.exercises});

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      name: json['name'] as String,
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
