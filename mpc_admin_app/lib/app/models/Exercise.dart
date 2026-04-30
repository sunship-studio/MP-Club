class Exercise {
  String id;
  String name;
  String? description;
  List<String> bodyParts;
  String? imageUrl;
  String? videoUrl;
  int? videoLengthSeconds;

  Exercise({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.videoUrl,
    this.videoLengthSeconds,
    required this.bodyParts,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoLengthSeconds: json['videoLengthSeconds'] as int?,
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((part) => part as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'videoLengthSeconds': videoLengthSeconds,
      'bodyParts': bodyParts,
    };
  }
}
