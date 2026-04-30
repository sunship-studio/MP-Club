class ExerciseSet {
  String reps;
  int rir;
  int weight;
  int? actualReps;

  ExerciseSet({required this.reps, required this.rir, required this.weight, this.actualReps});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'].toString(),
      rir: json['rir'] as int,
      weight: json['weight'] as int,
      actualReps: json['actualReps'] != null ? (json['actualReps'] as num).toInt() : null,
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

  @override
  // copyWith method to create a copy of the instance with modified values
  ExerciseSet copyWith({String? reps, int? rir, int? weight, int? actualReps}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      weight: weight ?? this.weight,
      actualReps: actualReps ?? this.actualReps,
    );
  }
}
