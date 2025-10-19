class ExerciseSet {
  int reps;
  int rir;
  int weight;

  ExerciseSet({required this.reps, required this.rir, required this.weight});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'] as int,
      rir: json['rir'] as int,
      weight: json['weight'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'reps': reps, 'rir': rir, 'weight': weight};
  }

  @override
  // copyWith method to create a copy of the instance with modified values
  ExerciseSet copyWith({int? reps, int? rir, int? weight}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      weight: weight ?? this.weight,
    );
  }
}
