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

  String get backgroundImage {
    if (days.any((day) => day.exercises.any((ex) => ex.videoUrl != null))) {
      return days
          .firstWhere((day) => day.exercises.any((ex) => ex.videoUrl != null))
          .exercises
          .firstWhere((ex) => ex.videoUrl != null)
          .videoUrl!
          .replaceAll('mp4', 'jpeg');
    }
    return '';
  }

  factory TrainingPlan.empty() {
    return TrainingPlan(days: [], name: "");
  }

  static String _toStringOrEmpty(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static DateTime? _toDateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'];
    final bodyPartsJson = json['bodyParts'];

    return TrainingPlan(
      lastUpdated: _toDateTimeOrNull(json['lastUpdated']),
      name: _toStringOrEmpty(json['name']),
      days:
          (daysJson is List)
              ? daysJson
                  .whereType<Map>()
                  .map(
                    (e) => TrainingDay.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : [],
      bodyParts:
          (bodyPartsJson is List)
              ? bodyPartsJson.map((e) => e.toString()).toList()
              : null,
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
