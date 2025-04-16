class CurrentSubcriber {
  String customerId;
  String email;
  String subscriptionId;
  String status;
  String firstNane;
  String lastName;
  int age;
  DateTime startDate;

  CurrentSubcriber({
    required this.customerId,
    required this.firstNane,
    required this.age,
    required this.lastName,
    required this.email,
    required this.subscriptionId,
    required this.status,
    required this.startDate,
  });

  factory CurrentSubcriber.fromJson(Map<String, dynamic> json) {
    return CurrentSubcriber(
      firstNane: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      customerId: json['customerId'],
      email: json['email'],
      subscriptionId: json['subscriptionId'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
    );
  }
}
