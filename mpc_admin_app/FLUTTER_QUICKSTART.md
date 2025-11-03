# Flutter Push Notifications - Quick Start Guide

## 🎯 Overview

This is a streamlined guide for Flutter developers to implement push notifications in the MP Club app. Follow these steps to get notifications working quickly.

---

## ⚡ Quick Setup (5 Steps)

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  http: ^1.1.0
```

Run:

```bash
flutter pub get
```

### Step 2: Firebase Configuration

#### iOS Setup

1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Add **Push Notifications** capability
4. Add **Background Modes** capability (enable Remote notifications)

#### Android Setup

1. Add `google-services.json` to `android/app/`
2. Update `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### Step 3: Copy Notification Service

Copy this file to `lib/services/notification_service.dart`:

👉 **See the complete code in `/examples/flutter_notification_service.dart`**

Or use this minimal version:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      InitializationSettings(android: android, iOS: ios),
    );

    // Get token
    _fcmToken = await _messaging.getToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) => _fcmToken = token);

    // Handle messages
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      _local.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default',
            'Default',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  void _handleTap(RemoteMessage message) {
    final type = message.data['type'];
    // Navigate based on notification type
    // navigationService.navigate(type, message.data);
  }
}
```

### Step 4: Initialize in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(MyApp());
}
```

### Step 5: Register Token with Backend

After user logs in, register the FCM token:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'YOUR_BACKEND_URL'; // e.g., https://api.mpclub.com

  Future<bool> registerFCMToken(String fcmToken, String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-app/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> removeFCMToken(String authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-app/notifications/remove-token'),
        headers: {'Authorization': authToken},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}

// Usage in your login flow
void afterLogin(String authToken) async {
  final fcmToken = NotificationService().fcmToken;
  if (fcmToken != null) {
    await ApiService().registerFCMToken(fcmToken, authToken);
  }
}

// Usage in your logout flow
void beforeLogout(String authToken) async {
  await ApiService().removeFCMToken(authToken);
}
```

---

## 🔔 Notification Types & Navigation

Handle different notification types in your app:

```dart
void handleNotification(RemoteMessage message) {
  final type = message.data['type'];

  switch (type) {
    case 'chat_message':
      // Navigate to chat
      final chatRoomId = message.data['chatRoomId'];
      Navigator.pushNamed(context, '/chat', arguments: chatRoomId);
      break;

    case 'workout_plan_update':
      // Navigate to workout plan
      Navigator.pushNamed(context, '/workout-plan');
      break;

    case 'check_in_reminder':
      // Navigate to check-in screen
      Navigator.pushNamed(context, '/check-in');
      break;
  }
}
```

### Notification Payloads

#### Chat Message

```json
{
  "notification": {
    "title": "New message from Shane",
    "body": "Message preview..."
  },
  "data": {
    "type": "chat_message",
    "chatRoomId": "user_id",
    "senderId": "Shane"
  }
}
```

#### Workout Plan Update

```json
{
  "notification": {
    "title": "Training Plan Updated",
    "body": "Shane has updated your training plan."
  },
  "data": {
    "type": "workout_plan_update"
  }
}
```

#### Check-in Reminder

```json
{
  "notification": {
    "title": "Time for your Check-in",
    "body": "Don't forget to log your progress!"
  },
  "data": {
    "type": "check_in_reminder"
  }
}
```

---

## 📱 Platform-Specific Configuration

### iOS Additional Setup

Update `ios/Runner/AppDelegate.swift`:

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

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
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

Add to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### Android Additional Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Optional: Custom notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
    </application>
</manifest>
```

---

## 🧪 Testing

### 1. Test FCM Token Generation

```dart
void testToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}
```

### 2. Test with Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter your device token
4. Send and verify notification appears

### 3. Test Backend Integration

```dart
// After login, check if token was registered
void checkTokenRegistration() async {
  final token = NotificationService().fcmToken;
  final success = await ApiService().registerFCMToken(token!, authToken);
  print('Token registered: $success');
}
```

### 4. Test Navigation

- Send test notification from Firebase Console
- Include data payload with type field
- Tap notification and verify correct screen opens

---

## ⚠️ Common Issues

### iOS: Notifications not appearing

- ✅ Push Notifications capability enabled in Xcode
- ✅ APNs certificate uploaded to Firebase Console
- ✅ Testing on physical device (not simulator)
- ✅ Notification permissions granted

### Android: Notifications not appearing

- ✅ Notification channel created (Android 8.0+)
- ✅ POST_NOTIFICATIONS permission granted (Android 13+)
- ✅ google-services.json in android/app/
- ✅ minSdkVersion is 21 or higher

### Token is null

- ✅ Firebase initialized before getting token
- ✅ Device has internet connection
- ✅ GoogleService files properly configured

### Backend not receiving token

- ✅ Auth token is valid and not expired
- ✅ Backend URL is correct
- ✅ Request headers include Authorization

---

## 📚 Backend API Reference

### Register Token

```
POST /mobile-app/notifications/register-token
Headers: {
  "Authorization": "Bearer <token>",
  "x-refresh-token": "<refresh-token>",
  "Content-Type": "application/json"
}
Body: {
  "fcmToken": "device_fcm_token"
}
```

### Remove Token

```
POST /mobile-app/notifications/remove-token
Headers: {
  "Authorization": "Bearer <token>",
  "x-refresh-token": "<refresh-token>"
}
```

---

## ✅ Checklist

Before going to production:

- [ ] Firebase project configured for both iOS and Android
- [ ] Dependencies added to pubspec.yaml
- [ ] GoogleService-Info.plist added to iOS project
- [ ] google-services.json added to Android project
- [ ] iOS Push Notifications capability enabled
- [ ] Android notification permissions added
- [ ] NotificationService implemented and initialized
- [ ] FCM token registration integrated with login flow
- [ ] Token removal integrated with logout flow
- [ ] Notification navigation implemented for all types
- [ ] Tested on both iOS and Android devices
- [ ] Tested foreground, background, and killed states
- [ ] Tested notification tap navigation

---

## 🔗 Resources

- **Complete Implementation**: See `/examples/flutter_notification_service.dart`
- **Backend Documentation**: See `BACKEND_PUSH_NOTIFICATIONS.md`
- **Full Flutter Guide**: See `FLUTTER_PUSH_NOTIFICATIONS.md`
- **Firebase Docs**: https://firebase.flutter.dev/docs/messaging/overview
- **FlutterFire**: https://firebase.flutter.dev

---

## 💡 Pro Tips

1. **Handle token refresh**: Listen to `onTokenRefresh` and update backend
2. **Test thoroughly**: Test all three states (foreground, background, killed)
3. **Use physical devices**: Notifications don't work reliably on simulators
4. **Validate data payloads**: Always check if data exists before accessing
5. **Graceful degradation**: Don't block user flow if notifications fail
6. **Clear notifications**: Clear relevant notifications when user opens related screens

---

**Last Updated:** November 2025
**Status:** ✅ Production Ready
**Support:** Contact backend team for API issues
