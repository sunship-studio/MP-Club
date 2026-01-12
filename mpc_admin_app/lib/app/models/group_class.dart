class GroupClassSpot {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime bookedAt;

  GroupClassSpot({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.bookedAt,
  });

  factory GroupClassSpot.fromJson(Map<String, dynamic> json) {
    return GroupClassSpot(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      bookedAt: DateTime.parse(json['bookedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }
}

class TimeSlot {
  final String time;
  final List<GroupClassSpot> spots;

  TimeSlot({required this.time, required this.spots});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      spots:
          (json['spots'] as List)
              .map((spot) => GroupClassSpot.fromJson(spot))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'time': time, 'spots': spots.map((spot) => spot.toJson()).toList()};
  }
}

class GroupClass {
  final String? id;
  final String title;
  final int durationMinutes;
  final List<TimeSlot> timeSlots;
  final DateTime date;
  final int spotsAvailable;
  final bool recurring;
  final String? dayOfWeek;

  GroupClass({
    this.id,
    required this.title,
    required this.durationMinutes,
    required this.timeSlots,
    required this.date,
    required this.spotsAvailable,
    this.recurring = false,
    this.dayOfWeek,
  });

  factory GroupClass.fromJson(Map<String, dynamic> json) {
    return GroupClass(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      timeSlots:
          (json['timeSlots'] as List)
              .map((slot) => TimeSlot.fromJson(slot))
              .toList(),
      date: DateTime.parse(json['date']),
      spotsAvailable: json['spotsAvailable'],
      recurring: json['recurring'] ?? false,
      dayOfWeek: json['dayOfWeek'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'durationMinutes': durationMinutes,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'date': date.toIso8601String(),
      'spotsAvailable': spotsAvailable,
      'recurring': recurring,
      if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
    };
  }

  GroupClass copyWith({
    String? id,
    String? title,
    int? durationMinutes,
    List<TimeSlot>? timeSlots,
    DateTime? date,
    int? spotsAvailable,
    bool? recurring,
    String? dayOfWeek,
  }) {
    return GroupClass(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeSlots: timeSlots ?? this.timeSlots,
      date: date ?? this.date,
      spotsAvailable: spotsAvailable ?? this.spotsAvailable,
      recurring: recurring ?? this.recurring,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }
}
