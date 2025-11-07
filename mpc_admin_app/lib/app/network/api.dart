import 'package:dio/dio.dart';
import 'package:mpc_admin_app/main.dart';

class ApiService {
  static String baseUrl =
      debug
          ? 'http://localhost:3500/admin-app'
          : 'https://mp-club-production.up.railway.app/admin-app';

  Dio dio = Dio();

  ApiService() {
    dio.options.baseUrl = baseUrl;
    dio.options.headers['token'] = admin_key;
    dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Response> get(String endpoint) async {
    try {
      Response response = await dio.get(endpoint);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await dio.post(endpoint, data: data);

      return response;
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<Response> postFormData({
    required String endpoint,
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      Response response = await dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post form data: $e');
    }
  }

  /// Register FCM token with backend
  Future<bool> saveFCMToken(String fcmToken) async {
    try {
      Response response = await post('/notifications/save-token', {
        'token': fcmToken,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error registering FCM token: $e');
      return false;
    }
  }

  /// Remove FCM token from backend
  Future<bool> removeFCMToken() async {
    try {
      Response response = await post('/notifications/remove_admin_token', {});
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error removing FCM token: $e');
      return false;
    }
  }
}

ApiService apiService = ApiService();
