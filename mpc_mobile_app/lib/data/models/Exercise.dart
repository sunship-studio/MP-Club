class Exercise {
  final String id;
  final List<String> bodyParts;
  final String name;
  final String videoUrl;

  final int videoLengthSeconds;
  final String? description;

  Exercise({
    required this.id,
    required this.bodyParts,
    required this.name,
    required this.videoUrl,
    required this.videoLengthSeconds,
    this.description,
  });

  get imageUrl {
    return videoUrl.replaceAll('mp4', 'jpeg');
  }

  // from JSON factory constructor
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'],
      videoLengthSeconds: json['videoLengthSeconds'],
      bodyParts: List<String>.from(json['bodyParts']),
      name: json['name'],
      videoUrl: json['videoUrl'],
      description: json['description'],
    );
  }

  // to JSON method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'videoLengthSeconds': videoLengthSeconds,
      'bodyParts': bodyParts,
      'name': name,
      'videoUrl': videoUrl,
      'description': description,
    };
  }
}
