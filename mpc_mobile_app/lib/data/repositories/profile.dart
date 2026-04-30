import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';

class ProfileRepository {
  ProfileRepository({required this.dioClient});
  DioClient dioClient;
  Future<bool> uploadProfilePicture(File file, String userId) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "userId": userId,
    });
    final response = await dioClient.postFormData(
      endpoint: '/profile/upload-profile-picture',
      formData: formData,
    );

    return response.statusCode == 200;
  }
}
