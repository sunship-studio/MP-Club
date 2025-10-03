import 'package:mpc_admin_app/main.dart';
import 'package:dio/dio.dart';

class ApiService {
  static String baseUrl =
      debug ? 'http://localhost:3500' : 'https://mpc-back-d6547de592cb.herokuapp.com';

  Dio dio = Dio();

  ApiService() {
    dio.options.baseUrl = baseUrl;
    dio.options.headers['token'] = "$admin_key";
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
}


ApiService apiService = ApiService();