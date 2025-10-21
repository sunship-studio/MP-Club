import 'package:dio/dio.dart';
import 'package:mpc_admin_app/main.dart';

class ApiService {
  static String baseUrl =
      debug
          ? 'http://localhost:3500/admin-app'
          : 'https://mpc-back-d6547de592cb.herokuapp.com/admin-app';

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
}

ApiService apiService = ApiService();
