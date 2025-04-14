class WaitingListEntry {
  String id;
  String firstName;
  String lastName;
  String email;
  DateTime dateApplied;
  String approvalStatus;
  int age;
  WeeklyAvailability weeklyAvailability;

  WaitingListEntry({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateApplied,
    required this.approvalStatus,
    required this.age,
    required this.weeklyAvailability,
  });

  factory WaitingListEntry.fromJson(Map<String, dynamic> json) {
    return WaitingListEntry(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      dateApplied: DateTime.parse(json['dateApplied']),
      approvalStatus: json['approvalStatus'],
      age: json['age'],
      weeklyAvailability: WeeklyAvailability.fromJson(
        json['weeklyAvailability'],
      ),
    );
  }
}

class WeeklyAvailability {
  List<DayAvailability> days;

  WeeklyAvailability({required this.days});

  factory WeeklyAvailability.fromJson(Map<String, dynamic> json) {
    List<DayAvailability> days = [];
    if (json['monday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['monday']).copyWith(day: "Monday"),
      );
    }
    if (json['tuesday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['tuesday']).copyWith(day: "Tuesday"),
      );
    }

    if (json['wednesday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['wednesday']).copyWith(day: "Wednesday"),
      );
    }
    if (json['thursday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['thursday']).copyWith(day: "Thursday"),
      );
    }
    if (json['friday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['friday']).copyWith(day: "Friday"),
      );
    }

    if (json['saturday']['available'] == true) {
      days.add(
        DayAvailability.fromJson(json['saturday']).copyWith(day: "Saturday"),
      );
    }

    return WeeklyAvailability(days: days);
  }
}

class DayAvailability {
  bool available;
  bool allDay;
  String day;
  String startTime;
  String endTime;

  DayAvailability({
    this.available = false,
    this.allDay = false,
    this.day = "",
    this.startTime = "",
    this.endTime = "",
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      available: json['available'],
      allDay: json['allDay'],

      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  // copy with method
  DayAvailability copyWith({
    bool? available,
    bool? allDay,
    String? day,
    String? startTime,
    String? endTime,
  }) {
    return DayAvailability(
      available: available ?? this.available,
      allDay: allDay ?? this.allDay,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
