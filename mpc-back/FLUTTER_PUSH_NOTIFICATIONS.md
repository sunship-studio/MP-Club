# Flutter Push Notifications Integration Guide

## Overview

This guide provides complete instructions for integrating Firebase Cloud Messaging (FCM) push notifications in your Flutter mobile app with the MP Club backend.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Flutter Dependencies](#flutter-dependencies)
4. [iOS Configuration](#ios-configuration)
5. [Android Configuration](#android-configuration)
6. [Flutter Implementation](#flutter-implementation)
7. [API Integration](#api-integration)
8. [Notification Types](#notification-types)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Firebase project created (same one used for the backend)
- Firebase Admin SDK JSON file configured in backend
- Flutter SDK installed
- Xcode (for iOS development)
- Android Studio (for Android development)

---

## Firebase Setup

### 1. Add Your Flutter App to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your MP Club project
3. Click "Add app" and choose iOS/Android
4. Follow the setup wizard for each platform
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 2. Enable Cloud Messaging

1. In Firebase Console, go to **Project Settings** > **Cloud Messaging**
2. Ensure FCM API is enabled
3. Note your Server Key and Sender ID (if needed for legacy systems)

---

## Flutter Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

Run:

```bash
flutter pub get
```

---

## iOS Configuration

### 1. Add GoogleService-Info.plist

1. Add `GoogleService-Info.plist` to `ios/Runner/` directory
2. In Xcode, add it to the Runner target

### 2. Enable Push Notifications Capability

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes** and enable:
   - Remote notifications
   - Background fetch

### 3. Update AppDelegate.swift

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

### 4. Configure Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

---

## Android Configuration

### 1. Add google-services.json

Place `google-services.json` in `android/app/` directory

### 2. Update build.gradle Files

**android/build.gradle:**

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle:**

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// Add this line at the bottom
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // FCM requires minimum API 21
    }
}
```

### 3. Add Android Permissions

In `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Add notification icon (optional, for better branding) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />

        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
    </application>
</manifest>
```

---

## Flutter Implementation

### 1. Initialize Firebase and Notifications

Create `lib/services/notification_service.dart`:

```dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  // You can show notification here if needed
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and notification handlers
  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Configure local notifications
    await _configureLocalNotifications();

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
      // Register new token with backend
      _registerTokenWithBackend(newToken);
    });

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  /// Configure local notifications for foreground display
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap from local notification
        if (details.payload != null) {
          _handleLocalNotificationTap(details.payload!);
        }
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      // Show local notification
      await _showLocalNotification(message);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_messages',
            'Chat Messages',
            channelDescription: 'Notifications for new chat messages',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap (background/terminated state)
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'chat_message':
        final chatRoomId = message.data['chatRoomId'];
        // Navigate to chat screen
        // navigationService.navigateToChatRoom(chatRoomId);
        break;

      case 'workout_plan_update':
        // Navigate to workout plan screen
        // navigationService.navigateToWorkoutPlan();
        break;

      case 'check_in_reminder':
        // Navigate to check-in screen
        // navigationService.navigateToCheckIn();
        break;

      default:
        // Handle default navigation
        break;
    }
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      print('Local notification tapped: $data');

      // Use the same handling logic
      final type = data['type'];
      // Navigate based on type...
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    // This should be called after user login
    // You'll need to pass the auth token
    // See API Integration section below
  }

  /// Subscribe to topic (optional, for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
```

### 2. Initialize in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notifications
  await NotificationService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MP Club',
      home: HomeScreen(),
    );
  }
}
```

---

## API Integration

### API Endpoints

The backend provides the following endpoints:

| Endpoint                                   | Method | Auth Required | Description        |
| ------------------------------------------ | ------ | ------------- | ------------------ |
| `/mobile-app/notifications/register-token` | POST   | Yes           | Register FCM token |
| `/mobile-app/notifications/remove-token`   | POST   | Yes           | Remove FCM token   |

### 1. Create API Service

Create `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'YOUR_BACKEND_URL'; // e.g., 'https://api.mpclub.com'

  String? _authToken;
  String? _refreshToken;

  void setTokens(String authToken, String refreshToken) {
    _authToken = authToken;
    _refreshToken = refreshToken;
  }

  /// Register FCM token with backend
  Future<bool> registerFCMToken(String fcmToken) async {
    if (_authToken == null) {
      print('Auth token not set');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-app/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken!,
          'x-refresh-token': _refreshToken ?? '',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('FCM token registered successfully');
        return true;
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering FCM token: $e');
      return false;
    }
  }

  /// Remove FCM token from backend (on logout)
  Future<bool> removeFCMToken() async {
    if (_authToken == null) {
      print('Auth token not set');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-app/notifications/remove-token'),
        headers: {
          'Authorization': _authToken!,
          'x-refresh-token': _refreshToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        print('FCM token removed successfully');
        return true;
      } else {
        print('Failed to remove FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error removing FCM token: $e');
      return false;
    }
  }
}
```

### 2. Register Token After Login

In your login flow:

```dart
class AuthService {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  Future<void> login(String email, String password) async {
    // Your login logic...
    final authToken = 'YOUR_AUTH_TOKEN';
    final refreshToken = 'YOUR_REFRESH_TOKEN';

    // Set tokens in API service
    _apiService.setTokens(authToken, refreshToken);

    // Register FCM token
    final fcmToken = _notificationService.fcmToken;
    if (fcmToken != null) {
      await _apiService.registerFCMToken(fcmToken);
    }
  }

  Future<void> logout() async {
    // Remove FCM token from backend
    await _apiService.removeFCMToken();

    // Clear local tokens
    _apiService.setTokens('', '');

    // Your logout logic...
  }
}
```

---

## Notification Types

The backend sends different types of notifications with specific data payloads:

### 1. Chat Message Notification

```json
{
  "notification": {
    "title": "New message from Shane",
    "body": "Message preview text..."
  },
  "data": {
    "type": "chat_message",
    "chatRoomId": "user_id_here",
    "senderId": "Shane"
  }
}
```

**Handling:**

```dart
case 'chat_message':
  final chatRoomId = message.data['chatRoomId'];
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(roomId: chatRoomId),
    ),
  );
  break;
```

### 2. Workout Plan Update

```json
{
  "notification": {
    "title": "Training Plan Updated",
    "body": "Shane has updated your training plan. Check it out!"
  },
  "data": {
    "type": "workout_plan_update"
  }
}
```

**Handling:**

```dart
case 'workout_plan_update':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WorkoutPlanScreen(),
    ),
  );
  break;
```

### 3. Check-in Reminder

```json
{
  "notification": {
    "title": "Time for your Check-in",
    "body": "Don't forget to log your progress today!"
  },
  "data": {
    "type": "check_in_reminder"
  }
}
```

**Handling:**

```dart
case 'check_in_reminder':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckInScreen(),
    ),
  );
  break;
```

---

## Best Practices

### 1. Token Management

- **Always register token after login**
- **Handle token refresh** - FCM tokens can be refreshed by Firebase
- **Remove token on logout** - This prevents notifications to logged-out users
- **Update token if changed** - Listen to `onTokenRefresh` and update backend

### 2. Notification Handling

- **Show notifications in foreground** - Use local notifications for better UX
- **Handle notification taps** - Navigate to appropriate screens
- **Parse notification data** - Always validate and handle data payloads safely

### 3. User Experience

- **Request permissions gracefully** - Explain why you need notification permission
- **Allow users to control notifications** - Provide settings to enable/disable
- **Group similar notifications** - Prevent notification spam
- **Clear notifications when appropriate** - Clear when user opens the app

### 4. Testing

- **Test on both platforms** - iOS and Android have different behaviors
- **Test all states** - Foreground, background, and terminated
- **Test notification taps** - Verify navigation works correctly
- **Test token refresh** - Simulate token changes

### 5. Error Handling

```dart
try {
  await _apiService.registerFCMToken(fcmToken);
} catch (e) {
  // Log error but don't block user flow
  print('Failed to register FCM token: $e');
  // Optionally retry later
}
```

### 6. Security

- **Never expose FCM tokens** - Keep them secure
- **Validate all notification data** - Don't trust data blindly
- **Use authenticated endpoints** - Always require auth for token registration

---

## Troubleshooting

### iOS Issues

**Problem:** Notifications not appearing on iOS

- Ensure Push Notifications capability is enabled
- Check that APNS certificate is valid in Firebase
- Verify `FirebaseAppDelegateProxyEnabled` is set to `false`
- Check device notification settings

**Problem:** App crashes on iOS

- Ensure you're using the latest firebase_messaging version
- Check that GoogleService-Info.plist is properly added

### Android Issues

**Problem:** Notifications not appearing on Android

- Verify notification channel is created (required for Android 8.0+)
- Check app notification permissions in device settings
- Ensure google-services.json is in the correct location

**Problem:** Build errors

- Run `flutter clean` and rebuild
- Ensure Google Services plugin is applied
- Check minSdkVersion is at least 21

### General Issues

**Problem:** Token is null

- Ensure Firebase is initialized before accessing token
- Check internet connection
- Verify Firebase project configuration

**Problem:** Backend not receiving token

- Check auth token is valid
- Verify API endpoint URL is correct
- Check request headers and body format

**Problem:** Notifications work in development but not production

- Ensure Firebase production keys are configured
- Check APNs certificates for iOS production
- Verify server key in Firebase Console

### Debug Commands

```dart
// Print FCM token
print('FCM Token: ${await FirebaseMessaging.instance.getToken()}');

// Check notification permissions
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Authorization status: ${settings.authorizationStatus}');

// Test notification handling
FirebaseMessaging.onMessage.listen((message) {
  print('Received message: ${message.notification?.title}');
  print('Message data: ${message.data}');
});
```

---

## Additional Resources

- [Firebase Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [APNs Configuration](https://firebase.google.com/docs/cloud-messaging/ios/certs)

---

## Support

For issues or questions:

1. Check this documentation first
2. Review Firebase Console for configuration issues
3. Test with Firebase console's test notification feature
4. Contact backend team for API-related issues

---

**Last Updated:** November 2025
**Version:** 1.0.0
