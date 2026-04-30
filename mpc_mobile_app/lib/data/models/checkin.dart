class CheckIn {
  final DateTime date;
  final double weight;
  final String? note;
  final String id;
  final String? imageUrl;
  final String? wellbeing;
  final List<String> photos;
  final String? biggestWin;
  final String? struggles;
  final String? questions;
  CheckIn({
    required this.date,
    required this.weight,
    this.note,
    this.imageUrl,
    required this.id,
    this.wellbeing,
    this.photos = const [],
    this.biggestWin,
    this.struggles,
    this.questions,
  });

  /// All available photos — uses [photos] if non-empty, falls back to [imageUrl]
  List<String> get allPhotos {
    if (photos.isNotEmpty) return photos;
    if (imageUrl != null) return [imageUrl!];
    return [];
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['_id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      wellbeing: json['wellbeing'] as String?,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      biggestWin: json['biggestWin'] as String?,
      struggles: json['struggles'] as String?,
      questions: json['questions'] as String?,
    );
  }
}
