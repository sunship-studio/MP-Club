import 'package:mpc_admin_app/app/models/TrainingPlan.dart';

class User {
  final String id;
  final String? token;
  final String? refreshToken;
  final String subscriptionId;
  final String status;
  final String type;
  final int? caloriesPerDay;
  final bool? hasPassword;
  final DateTime? lastLogin;
  final String? passwordHash;
  final TrainingPlan trainingPlan;
  final DateTime startDate;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String? cancelToken;

  User({
    required this.id,
    this.token,
    this.refreshToken,
    required this.subscriptionId,
    required this.status,
    required this.type,
    this.caloriesPerDay,
    this.hasPassword,
    this.lastLogin,
    this.passwordHash,
    required this.trainingPlan,
    required this.startDate,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    this.cancelToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      subscriptionId: json['subscriptionId'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      caloriesPerDay: json['caloriesPerDay'] as int?,
      hasPassword: json['hasPassword'] as bool?,
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.parse(json['lastLogin'] as String)
              : null,
      passwordHash: json['passwordHash'] as String?,
      trainingPlan:
          TrainingPlan.fromJson(json['trainingPlan'] as List<dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      cancelToken: json['cancelToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'subscriptionId': subscriptionId,
      'status': status,
      'type': type,
      if (caloriesPerDay != null) 'caloriesPerDay': caloriesPerDay,
      if (hasPassword != null) 'hasPassword': hasPassword,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      if (passwordHash != null) 'passwordHash': passwordHash,
      'trainingPlan': trainingPlan.toJson(),
      'startDate': startDate.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      if (cancelToken != null) 'cancelToken': cancelToken,
    };
  }

  User copyWith({
    String? id,
    String? token,
    String? refreshToken,
    String? subscriptionId,
    String? status,
    String? type,
    int? caloriesPerDay,
    bool? hasPassword,
    DateTime? lastLogin,
    String? passwordHash,
    TrainingPlan? trainingPlan,
    DateTime? startDate,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? cancelToken,
  }) {
    return User(
      id: id ?? this.id,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      status: status ?? this.status,
      type: type ?? this.type,
      caloriesPerDay: caloriesPerDay ?? this.caloriesPerDay,
      hasPassword: hasPassword ?? this.hasPassword,
      lastLogin: lastLogin ?? this.lastLogin,
      passwordHash: passwordHash ?? this.passwordHash,
      trainingPlan: trainingPlan ?? this.trainingPlan,
      startDate: startDate ?? this.startDate,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
