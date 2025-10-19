
import 'package:mpc_mobile_app/data/models/UserExercise.dart';


class TrainingDay {
  String name;
  List<UserExercise> exercises;

  TrainingDay({this.name = "", required this.exercises});

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      name: json['name'] as String,
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((e) => UserExercise.fromJson(e as Map<String, dynamic>))
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
