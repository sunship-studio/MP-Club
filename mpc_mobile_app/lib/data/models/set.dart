class ExerciseSet {
  String reps;
  int rir;
  int weight;
  int? actualReps;

  ExerciseSet({required this.reps, required this.rir, required this.weight, this.actualReps});

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _toRepsString(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.round().toString();
    return '0';
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: _toRepsString(json['reps']),
      rir: _toInt(json['rir']),
      weight: _toInt(json['weight']),
      actualReps: json['actualReps'] != null ? _toInt(json['actualReps']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'rir': rir,
      'weight': weight,
      if (actualReps != null) 'actualReps': actualReps,
    };
  }

  ExerciseSet copyWith({String? reps, int? rir, int? weight, int? actualReps}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      weight: weight ?? this.weight,
      actualReps: actualReps ?? this.actualReps,
    );
  }
}
