class Exercise {
  String name;
  String id;
  int sets;
  int reps;
  int minutes;
  int seconds;
  int weight;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.minutes,
    required this.seconds,
    required this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['exerciseId'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      minutes: json['minutes'] as int? ?? 0,
      seconds: json['seconds'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'minutes': minutes,
      'seconds': seconds,
      'weight': weight,
    };
  }
}