import 'package:mpc_admin_app/app/models/TrainingDay.dart';

class PublicPlan {
  String? id;
  String name;
  String? excelFileUrl;

  List<TrainingDay> days;
  double price;
  String? stripeProductId;
  DateTime? createdAt;
  DateTime? updatedAt;

  PublicPlan({
    this.id,
    required this.name,
    this.excelFileUrl,

    List<TrainingDay>? days,
    required this.price,
    this.stripeProductId,
    this.createdAt,
    this.updatedAt,
  }) : days = days ?? [];

  factory PublicPlan.fromJson(Map<String, dynamic> json) {
    // Handle listOfExercises which could be a List or might need parsing
    List<String> exercises = [];
    if (json['listOfExercises'] != null) {
      if (json['listOfExercises'] is List) {
        exercises =
            (json['listOfExercises'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
      }
    }

    // Handle days
    List<TrainingDay> days = [];
    if (json['days'] != null && json['days'] is List) {
      days =
          (json['days'] as List<dynamic>)
              .map((e) => TrainingDay.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    return PublicPlan(
      id: json['_id'] as String?,
      name: json['name'] as String,
      excelFileUrl: json['excelFileUrl'] as String? ?? '',

      days: days,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stripeProductId: json['stripeProductId'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'excelFileUrl': excelFileUrl,

      'days': days.map((e) => e.toJson()).toList(),
      'price': price,
      if (stripeProductId != null) 'stripeProductId': stripeProductId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
