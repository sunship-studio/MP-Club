import 'package:mpc_mobile_app/data/models/TrainingPlan.dart';
import 'package:mpc_mobile_app/data/models/calories_log.dart';
import 'package:mpc_mobile_app/data/models/checkin.dart';
import 'package:mpc_mobile_app/data/models/workout.dart';

class User {
  final String customerId;
  final String id;
  final String? token;
  final String? refreshToken;
  final int? targetWeight;
  final String? profilePictureUrl;
  final String subscriptionId;
  final String status;
  final String type;
  final List<Workout> doneWorkouts;
  final List<CheckIn> checkIns;
  final int? caloriesPerDay;
  final List<CaloriesLog> caloriesLogs;
  final bool? hasPassword;
  final DateTime? lastLogin;
  final String? password;
  final TrainingPlan trainingPlan;
  final DateTime startDate;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final String? cancelToken;

  User({
    required this.profilePictureUrl,
    required this.id,
    required this.checkIns,
    required this.customerId,
    required this.caloriesLogs,
    this.token,
    this.refreshToken,
    required this.doneWorkouts,
    this.targetWeight,
    required this.subscriptionId,
    required this.status,
    required this.type,
    this.caloriesPerDay,
    this.hasPassword,
    this.lastLogin,
    this.password,
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
      customerId: json['customerId'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      token: json['token'] as String?,
      targetWeight: json['targetWeight'] as int?,
      doneWorkouts:
          json['doneWorkouts'] != null
              ? (json['doneWorkouts'] as List<dynamic>)
                  .map((item) => Workout.fromJson(item as Map<String, dynamic>))
                  .toList()
              : [],
      caloriesLogs:
          json['caloriesLogs'] != null
              ? (json['caloriesLogs'] as List<dynamic>)
                  .map(
                    (item) =>
                        CaloriesLog.fromJson(item as Map<String, dynamic>),
                  )
                  .toList()
              : [],
      refreshToken: json['refreshToken'] as String?,
      subscriptionId: json['subscriptionId'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      caloriesPerDay: json['caloriesPerDay'] as int?,
      checkIns:
          (json['checkIns'] as List<dynamic>)
              .map((item) => CheckIn.fromJson(item as Map<String, dynamic>))
              .toList(),
      hasPassword: json['hasPassword'] as bool?,
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.parse(json['lastLogin'] as String)
              : null,
      password: json['password'] as String?,
      trainingPlan: TrainingPlan.fromJson(
        json['trainingPlan'] as Map<String, dynamic>,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      cancelToken: json['cancelToken'] as String?,
    );
  }
}
