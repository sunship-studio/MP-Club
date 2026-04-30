import 'package:dio/dio.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';

class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;
  DioClient(this.dio, this.tokenStorage);
  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';
      print('GET $endpoint with headers: ${dio.options.headers}');
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }
      return response;
    } on DioException catch (e) {
      throw Exception('Failed to load data: ${e.message}');
    }
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';
      final response = await dio.post(endpoint, data: data);
      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        return e.response!;
      }
      throw Exception('Failed to post data: ${e.message}');
    }
  }

  Future<Response> postFormData({
    required String endpoint,
    required FormData formData,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';
      final response = await dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        return e.response!;
      }
      throw Exception('Failed to post form data: ${e.message}');
    }
  }

  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';
      final response = await dio.put(endpoint, data: data);
      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }

      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        return e.response!;
      }
      throw Exception('Failed to put data: ${e.message}');
    }
  }

  /// Register FCM token with backend
  Future<Response> registerFCMToken(String fcmToken) async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';

      final response = await dio.post(
        '/notifications/register-token',
        data: {'fcmToken': fcmToken},
      );

      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }

      return response;
    } on DioException catch (e) {
      throw Exception('Failed to register FCM token: ${e.message}');
    }
  }

  /// Remove FCM token from backend (on logout)
  Future<Response> removeFCMToken() async {
    try {
      dio.options.headers['authorization'] =
          await tokenStorage.getAccessToken() ?? '';
      dio.options.headers['x-refresh-token'] =
          await tokenStorage.getRefreshToken() ?? '';

      final response = await dio.post('/notifications/remove-token');

      if (response.headers['authorization'] != null &&
          response.headers['x-refresh-token'] != null) {
        await tokenStorage.saveTokens(
          accessToken: response.headers['authorization']!.first,
          refreshToken: response.headers['x-refresh-token']!.first,
        );
      }

      return response;
    } on DioException catch (e) {
      throw Exception('Failed to remove FCM token: ${e.message}');
    }
  }
}
