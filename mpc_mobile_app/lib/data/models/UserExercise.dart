import 'package:mpc_mobile_app/data/models/set.dart';

class UserExercise {
  String name;
  String? id;
  List<ExerciseSet>? sets = [
    ExerciseSet(reps: 10, rir: 2, weight: 0),
    ExerciseSet(reps: 10, rir: 2, weight: 0),
    ExerciseSet(reps: 10, rir: 2, weight: 0),
  ];
  int? minutes;
  int? seconds;

  List<String> bodyParts = [];

  UserExercise({
    this.id,
    required this.name,
    this.sets,
    this.minutes = 0,
    this.seconds = 0,
    required this.bodyParts,
  });

  factory UserExercise.fromJson(Map<String, dynamic> json) {
    return UserExercise(
      id: json['exerciseId'] as String,

      name: json['name'] as String,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
              .toList(),

      minutes: json['minutes'] as int? ?? 0,
      seconds: json['seconds'] as int? ?? 0,
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': id,
      'name': name,
      'sets': sets?.map((e) => e.toJson()).toList(),
      'bodyParts': bodyParts,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}
