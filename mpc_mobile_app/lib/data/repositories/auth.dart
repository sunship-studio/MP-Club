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

  Future<User> getUser() async {
    final response = await dio.get(endpoint: '/auth/user');
    print('User response data: ${response.data}');
    return User.fromJson(response.data);
    throw Exception('Failed to load user data');
  }
}

class AuthResult {
  final dynamic data;
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message, this.data});
}
