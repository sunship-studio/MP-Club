import 'package:mpc_admin_app/app/models/TrainingDay.dart';

class TrainingPlan {
  List<TrainingDay> days;
  String name;
  List<String>? bodyParts;
  TrainingPlan({required this.days, required this.name, this.bodyParts});

  factory TrainingPlan.empty() {
    return TrainingPlan(days: [], name: "Plan Nam");
  }

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      name: json['name'] as String,
      days:
          (json['days'] as List<dynamic>)
              .map((e) => TrainingDay.fromJson(e as Map<String, dynamic>))
              .toList(),
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'days': days.map((e) => e.toJson()).toList(),
      'bodyParts': bodyParts,
    };
  }
}
