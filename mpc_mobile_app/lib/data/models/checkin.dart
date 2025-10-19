class CheckIn {
  final DateTime date;
  final double weight;
  final String? note;
  final String id;
  final String? imageUrl;
  CheckIn({
    required this.date,
    required this.weight,
    this.note,
    this.imageUrl,
    required this.id,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['_id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
