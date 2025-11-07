// Example: How to integrate FCM token registration in your auth flow
// This is just an example - adapt it to your actual authentication implementation

import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/network/api.dart';
import 'package:mpc_admin_app/app/services/notification_service.dart';

/// Example authentication service showing FCM token integration
class AuthService {
  /// Call this after successful login
  Future<void> handleSuccessfulLogin() async {
    // Your existing login logic here...

    // Register FCM token with backend
    await _registerFCMToken();
  }

  /// Call this before logout
  Future<void> handleLogout() async {
    // Remove FCM token from backend
    await _removeFCMToken();

    // Your existing logout logic here...
  }

  /// Register FCM token with backend
  Future<void> _registerFCMToken() async {
    try {
      final fcmToken = NotificationService().fcmToken;

      if (fcmToken == null) {
        print('⚠️ FCM token not available yet');
        return;
      }

      final success = await apiService.saveFCMToken(fcmToken);

      if (success) {
        print('✅ FCM token saved successfully');
      } else {
        print('❌ Failed to save FCM token');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Remove FCM token from backend
  Future<void> _removeFCMToken() async {
    try {
      final success = await apiService.removeFCMToken();

      if (success) {
        print('✅ FCM token removed successfully');
      } else {
        print('❌ Failed to remove FCM token');
      }
    } catch (e) {
      print('❌ Error removing FCM token: $e');
    }
  }
}

/// Example usage in a login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    // Your login logic...
    bool loginSuccessful = true; // Replace with actual login result

    if (loginSuccessful) {
      await _authService.handleSuccessfulLogin();

      // Navigate to home or wherever
    }
  }

  Future<void> _handleLogout() async {
    await _authService.handleLogout();

    // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    // Your UI here
    return Container();
  }
}

/// Quick integration snippet for existing code
///
/// After login:
/// ```dart
/// final fcmToken = NotificationService().fcmToken;
/// if (fcmToken != null) {
///   await apiService.registerFCMToken(fcmToken);
/// }
/// ```
///
/// Before logout:
/// ```dart
/// await apiService.removeFCMToken();
/// ```
