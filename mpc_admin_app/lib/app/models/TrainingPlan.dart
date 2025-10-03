import 'package:mpc_admin_app/app/models/TrainingDay.dart';

class TrainingPlan {
  List<TrainingDay> days;
  TrainingPlan({required this.days});

  factory TrainingPlan.empty() {
    return TrainingPlan(days: []);
  }

  factory TrainingPlan.fromJson(List<dynamic> json) {
    return TrainingPlan(
      days: json.map((e) => TrainingDay.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((e) => e.toJson()).toList(),
    };
  }
}
