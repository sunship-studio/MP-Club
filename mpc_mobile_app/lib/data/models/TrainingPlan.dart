import 'package:mpc_mobile_app/data/models/TrainingDay.dart';

class TrainingPlan {
  List<TrainingDay> days;
  String name;
  List<String>? bodyParts;
  DateTime? lastUpdated;
  TrainingPlan({
    required this.days,
    required this.name,
    this.bodyParts,
    this.lastUpdated,
  });

  factory TrainingPlan.empty() {
    return TrainingPlan(days: [], name: "");
  }

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'] as String)
              : null,
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
