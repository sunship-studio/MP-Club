// lib/services/image_service.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final _picker = ImagePicker();

  String get baseUrl => 'http://192.168.1.70:3500'; // Change to your server

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Upload image to server
  Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await getIt<DioClient>().postFormData(
        endpoint: '$baseUrl/api/chat/upload-image',
        formData: formData,
        onSendProgress: (sent, total) {
          print('Upload progress: ${sent / total * 100}%');
        },
      );

      if (response.data['success'] == true) {
        return {
          'url': response.data['url'],
          'filename': response.data['filename'],
          'size': response.data['size'],
          'type': response.data['mimetype'],
        };
      }
    } catch (e) {
      print('Upload error: $e');
    }
    return null;
  }
}
