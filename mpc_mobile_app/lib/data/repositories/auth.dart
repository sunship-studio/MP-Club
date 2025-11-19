import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class AuthRepository {
  final DioClient dio;
  final FlutterSecureStorage storage;

  AuthRepository({required this.dio, required this.storage});

  Future<AuthResult> checkEmail(String email) async {
    final response = await dio.post('/auth/check-email', {'email': email});
    if (response.statusCode != 200) {
      return AuthResult(
        success: false,
        message: response.data['message'] ?? 'Error checking email',
      );
    }

    return AuthResult(success: response.statusCode == 200, data: response.data);
  }

  Future<AuthResult> login(String email, String password) async {
    final response = await dio.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (response.statusCode != 200) {
      return AuthResult(
        success: false,
        message: response.data['message'] ?? 'Error logging in',
      );
    }
    return AuthResult(success: response.statusCode == 200, data: response.data);
  }

  Future<AuthResult> forgotPassword(String email) async {
    final response = await dio.post('/auth/forgot-password', {'email': email});
    return AuthResult(
      success: response.statusCode == 200,
      message: response.data['message'],
      data: response.data,
    );
  }

  Future<AuthResult> setPassword(String email, String newPassword) async {
    final response = await dio.post('/auth/set-password', {
      'email': email,
      'newPassword': newPassword,
    });
    return AuthResult(
      success: response.statusCode == 200,
      message: response.data['message'],
      data: response.data,
    );
  }

  Future<User?> setNewPassword(String token, String password) async {
    final response = await dio.post('/auth/new-password', {
      'token': token,
      'password': password,
    });
    return response.statusCode == 200 ? User.fromJson(response.data) : null;
  }

  Future<User> getUser() async {
    final response = await dio.get(endpoint: '/auth/user');

    return User.fromJson(response.data);
    throw Exception('Failed to load user data');
  }

  /// Create account with Apple subscription
  Future<AuthResult> createAccountWithAppleSubscription({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    required String appleReceiptData,
    required String subscriptionId,
    int? targetWeight,
  }) async {
    print(
      'Creating account with Apple subscription for $firstName $lastName, email $email, age $age, subscriptionId $subscriptionId, targetWeight $targetWeight, receiptData length ${appleReceiptData.length}',
    );
    try {
      final response = await dio
          .post('/auth/create-account-apple-subscription', {
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'age': age,
            'appleReceiptData': appleReceiptData,
            'subscriptionId': subscriptionId,
            if (targetWeight != null) 'targetWeight': targetWeight,
          });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend returns tokens in headers
        // Your DioClient should handle saving them automatically
        return AuthResult(
          success: true,
          message: response.data['message'] ?? 'Account created successfully',
          data: response.data['user'],
        );
      } else {
        return AuthResult(
          success: false,
          message: response.data['message'] ?? 'Failed to create account',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Error creating account: $e');
    }
  }
}

class AuthResult {
  final dynamic data;
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message, this.data});
}
