class CurrentSubcriber {
  String customerId;
  String email;
  String subscriptionId;
  String status;
  int startDate;

  CurrentSubcriber({
    required this.customerId,
    required this.email,
    required this.subscriptionId,
    required this.status,
    required this.startDate,
  });

  factory CurrentSubcriber.fromJson(Map<String, dynamic> json) {
    return CurrentSubcriber(
      customerId: json['customerId'],
      email: json['email'],
      subscriptionId: json['subscriptionId'],
      status: json['status'],
      startDate: json['startDate'],
    );
  }
}
