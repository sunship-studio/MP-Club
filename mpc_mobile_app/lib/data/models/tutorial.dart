class Tutorial {
  String id;
  String title;
  String description;
  String url;
  int durationSeconds;
  List<String> bodyParts;

  Tutorial({
    required this.id,
    required this.bodyParts,
    required this.title,
    required this.description,
    required this.url,
    required this.durationSeconds,
  });
}
