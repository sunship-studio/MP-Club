# Shane's Admin App - Flutter Push Notifications Setup

## 🚀 Quick Implementation Guide

### Step 1: Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  http: ^1.1.0
```

Run: `flutter pub get`

### Step 2: Configure Firebase

**iOS:**

- Add `GoogleService-Info.plist` to `ios/Runner/`
- Enable Push Notifications in Xcode capabilities
- Enable Background Modes → Remote notifications

**Android:**

- Add `google-services.json` to `android/app/`
- Update `android/build.gradle`:
  ```gradle
  dependencies {
      classpath 'com.google.gms:google-services:4.4.0'
  }
  ```
- Update `android/app/build.gradle`:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  ```

### Step 3: Create Notification Service

Create `lib/services/admin_notification_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

class AdminNotificationService {
  static final _instance = AdminNotificationService._();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications
    await _local.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Get token
    _fcmToken = await _messaging.getToken();
    print('Shane FCM Token: $_fcmToken');

    // Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      registerToken(token);
    });
  }

  void _handleForeground(RemoteMessage message) {
    if (message.notification != null) {
      _local.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'admin_notifications',
            'Admin Notifications',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleTap(RemoteMessage message) {
    final type = message.data['type'];
    final chatRoomId = message.data['chatRoomId'];
    final userId = message.data['userId'];

    // Navigate based on type
    switch (type) {
      case 'chat_message':
        // Navigate to chat with client
        // Get.toNamed('/chat', arguments: chatRoomId);
        break;
      case 'new_user':
        // Navigate to user details
        // Get.toNamed('/user-details', arguments: userId);
        break;
      case 'payment_received':
        // Navigate to payments
        // Get.toNamed('/payments', arguments: userId);
        break;
    }
  }

  Future<bool> registerToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_URL/mobile-app/notifications/save_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'debug': false}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error registering token: $e');
      return false;
    }
  }

  Future<bool> removeToken() async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_URL/mobile-app/notifications/remove_admin_token'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing token: $e');
      return false;
    }
  }

  String? get fcmToken => _fcmToken;
}
```

### Step 4: Initialize in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/admin_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdminNotificationService().initialize();
  runApp(MyApp());
}
```

### Step 5: Integrate with Auth

```dart
// After Shane logs in
Future<void> onShaneLogin() async {
  final token = AdminNotificationService().fcmToken;
  if (token != null) {
    final success = await AdminNotificationService().registerToken(token);
    print('Token registered: $success');
  }
}

// Before Shane logs out
Future<void> onShaneLogout() async {
  await AdminNotificationService().removeToken();
}
```

### Step 6: Handle Navigation (Optional)

```dart
// If using GetX
class NotificationRouter {
  static void handleNotification(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'chat_message':
        Get.toNamed('/chat', arguments: {
          'clientId': data['chatRoomId'],
        });
        break;

      case 'new_user':
        Get.toNamed('/user-details', arguments: {
          'userId': data['userId'],
        });
        break;

      case 'payment_received':
        Get.toNamed('/payments', arguments: {
          'userId': data['userId'],
          'amount': data['amount'],
        });
        break;
    }
  }
}

// Update _handleTap in AdminNotificationService
void _handleTap(RemoteMessage message) {
  NotificationRouter.handleNotification(message.data);
}
```

## 📱 Notification Types Shane Receives

### 1. New Client Message

```json
{
  "type": "chat_message",
  "chatRoomId": "client_id",
  "senderId": "client_id"
}
```

**Action:** Navigate to chat with that client

### 2. New User Signup

```json
{
  "type": "new_user",
  "userId": "user_id"
}
```

**Action:** Navigate to user details

### 3. Payment Received

```json
{
  "type": "payment_received",
  "userId": "user_id",
  "amount": "99.99"
}
```

**Action:** Navigate to payments/user profile

## 🧪 Testing

### 1. Test Token Registration

```dart
void testTokenRegistration() async {
  final token = AdminNotificationService().fcmToken;
  print('Current token: $token');

  if (token != null) {
    final success = await AdminNotificationService().registerToken(token);
    print('Registration success: $success');
  }
}
```

### 2. Test with Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter Shane's FCM token (from logs)
4. Add data payload:
   ```json
   {
     "type": "chat_message",
     "chatRoomId": "test_client_id"
   }
   ```
5. Send and verify notification appears

### 3. Test Navigation

- Send test notification
- Tap notification
- Verify app navigates to correct screen

## ⚙️ Configuration

### Backend URL

Update in `admin_notification_service.dart`:

```dart
static const baseUrl = 'https://api.mpclub.com'; // or your backend URL
```

### Android Notification Channel

Already configured as `admin_notifications` - matches backend

### iOS Setup

Add to `ios/Runner/AppDelegate.swift`:

```swift
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
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

## 🔒 Important Notes

- ✅ Register token **immediately after login**
- ✅ Remove token **before logout**
- ✅ Handle token refresh automatically (already in code)
- ✅ Test on **physical devices** (not simulators)
- ✅ Request notification permissions on app start
- ✅ iOS requires APNs certificates in Firebase Console

## ✅ Checklist

- [ ] Firebase dependencies added
- [ ] Firebase configured for iOS and Android
- [ ] AdminNotificationService created
- [ ] Service initialized in main.dart
- [ ] Token registration integrated with login
- [ ] Token removal integrated with logout
- [ ] Navigation handlers implemented
- [ ] Backend URL configured
- [ ] Tested on physical iOS device
- [ ] Tested on physical Android device
- [ ] APNs certificates uploaded to Firebase (iOS)

## 🆘 Troubleshooting

**Token is null:**

- Ensure Firebase is initialized before getting token
- Check internet connection
- Verify Firebase configuration files

**Notifications not appearing:**

- Check device notification settings
- Verify token is registered in backend
- Test with Firebase Console first
- iOS: Check APNs certificates

**Navigation not working:**

- Verify notification data payload includes required fields
- Check navigation routes are defined
- Test with print statements in \_handleTap

---

**Backend Endpoints:**

- Register: `POST /mobile-app/notifications/save_token`
- Remove: `POST /mobile-app/notifications/remove_admin_token`

**See also:** `ADMIN_APP_DOCUMENTATION.md` for complete details
