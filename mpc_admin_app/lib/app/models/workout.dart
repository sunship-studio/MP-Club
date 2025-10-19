import 'package:mpc_admin_app/app/models/TrainingDay.dart';

class Workout {
  final TrainingDay workout;
  DateTime date;

  Workout({required this.workout, required this.date});

  Map<String, dynamic> toJson() {
    return {'workout': workout.toJson(), 'date': date.toIso8601String()};
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      workout: TrainingDay.fromJson(json['workout']),
      date: DateTime.parse(json['date']),
    );
  }
}
