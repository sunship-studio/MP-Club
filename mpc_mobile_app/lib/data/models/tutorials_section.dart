import 'package:mpc_mobile_app/data/models/Exercise.dart';

class TutorialsSection {
  List<Exercise> forYou;
  List<dynamic> byBodyPart;

  TutorialsSection({required this.forYou, required this.byBodyPart});

  factory TutorialsSection.fromJson(Map<String, dynamic> json) {
    return TutorialsSection(
      forYou: List<Exercise>.from(
        json['forYou'].map((x) => Exercise.fromJson(x)),
      ),
      byBodyPart: json['byBodyPart'],
    );
  }
}
