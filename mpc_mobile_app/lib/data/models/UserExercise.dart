import 'package:mpc_mobile_app/data/models/set.dart';

class UserExercise {
  String name;
  String? id;
  String? videoUrl;
  List<ExerciseSet>? sets = [
    ExerciseSet(reps: '10', rir: 2, weight: 0),
    ExerciseSet(reps: '10', rir: 2, weight: 0),
    ExerciseSet(reps: '10', rir: 2, weight: 0),
  ];
  int? minutes;
  int? seconds;

  List<String> bodyParts = [];

  UserExercise({
    this.id,
    required this.name,
    this.videoUrl,
    this.sets,
    this.minutes = 0,
    this.seconds = 0,
    required this.bodyParts,
  });

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory UserExercise.fromJson(Map<String, dynamic> json) {
    final setsJson = json['sets'];
    final bodyPartsJson = json['bodyParts'];

    return UserExercise(
      id:
          _toStringOrNull(json['exerciseId']) ??
          _toStringOrNull(json['id']) ??
          _toStringOrNull(json['_id']),

      name: _toStringOrNull(json['name']) ?? '',
      videoUrl: _toStringOrNull(json['videoUrl']),
      sets:
          (setsJson is List)
              ? setsJson
                  .whereType<Map>()
                  .map(
                    (e) => ExerciseSet.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : null,

      minutes: _toInt(json['minutes']),
      seconds: _toInt(json['seconds']),
      bodyParts:
          (bodyPartsJson is List)
              ? bodyPartsJson.map((e) => e.toString()).toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': id,
      'name': name,
      'videoUrl': videoUrl,
      'sets': sets?.map((e) => e.toJson()).toList(),
      'bodyParts': bodyParts,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  UserExercise deepCopy() {
    return UserExercise(
      id: id,
      name: name,
      videoUrl: videoUrl,
      sets: sets?.map((set) => set.copyWith()).toList(),
      minutes: minutes,
      seconds: seconds,
      bodyParts: List<String>.from(bodyParts),
    );
  }
}
