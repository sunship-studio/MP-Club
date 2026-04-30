class CaloriesLog {
  final String? note;
  final int calories;
  final DateTime date;

  CaloriesLog({this.note, required this.calories, required this.date});
  factory CaloriesLog.fromJson(Map<String, dynamic> json) {
    return CaloriesLog(
      note: json['note'] as String?,
      calories: json['calories'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
