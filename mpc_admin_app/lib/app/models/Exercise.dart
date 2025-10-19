class Exercise {
  String id;
  String name;
  String? description;
  List<String> bodyParts;
  String? imageUrl;
  String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.videoUrl,
    required this.bodyParts,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      bodyParts: (json['bodyParts'] as List<dynamic>?)
              ?.map((part) => part as String)
              .toList() ??
          [],
    );
  }
}
