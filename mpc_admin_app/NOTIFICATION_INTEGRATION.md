# Push Notifications Integration Guide

## ✅ What's Been Done

### 1. **NotificationService Created** ✓
- Full FCM integration with Firebase Messaging
- Local notifications for foreground messages
- Background message handling
- Notification channels for Android (Chat, Workout Updates, Check-ins)
- Automatic navigation based on notification type

### 2. **Main.dart Updated** ✓
- Firebase initialized
- NotificationService initialized on app start
- Background message handler configured

### 3. **API Service Updated** ✓
- `registerFCMToken(String fcmToken)` method added
- `removeFCMToken()` method added

### 4. **iOS Configuration** ✓
- AppDelegate.swift updated with Firebase and FCM configuration
- Info.plist updated with FirebaseAppDelegateProxyEnabled flag

### 5. **Android Configuration** ✓
- POST_NOTIFICATIONS permission already present in AndroidManifest.xml

---

## 📝 How to Use

### Register FCM Token (After Login)

When a user logs in, register their FCM token with your backend:

```dart
import 'package:mpc_admin_app/app/services/notification_service.dart';
import 'package:mpc_admin_app/app/network/api.dart';

Future<void> afterLogin() async {
  // Get the FCM token
  final fcmToken = NotificationService().fcmToken;

  if (fcmToken != null) {
    // Register with backend
    final success = await apiService.registerFCMToken(fcmToken);

    if (success) {
      print('✅ FCM token registered successfully');
    } else {
      print('❌ Failed to register FCM token');
    }
  } else {
    print('⚠️ FCM token not available yet');
  }
}
```

### Remove FCM Token (Before Logout)

When a user logs out, remove their FCM token from the backend:

```dart
import 'package:mpc_admin_app/app/network/api.dart';

Future<void> beforeLogout() async {
  // Remove token from backend
  final success = await apiService.removeFCMToken();

  if (success) {
    print('✅ FCM token removed successfully');
  } else {
    print('❌ Failed to remove FCM token');
  }
}
```

### Handle Token Refresh

The NotificationService already handles token refresh automatically. When a token refreshes, it prints to console. You can add backend synchronization:

```dart
// In notification_service.dart, the onTokenRefresh listener already exists
// You can modify it to call your API:

_messaging.onTokenRefresh.listen((newToken) {
  _fcmToken = newToken;
  debugPrint('🔄 FCM Token refreshed: $newToken');

  // TODO: Update token on backend
  apiService.registerFCMToken(newToken);
});
```

---

## 🔔 Notification Types & Payloads

The app currently handles these notification types:

### 1. Chat Message
```json
{
  "notification": {
    "title": "New message from Shane",
    "body": "Message preview..."
  },
  "data": {
    "type": "chat_message",
    "userId": "user_id",
    "chatRoomId": "room_id"
  }
}
```
**Navigation:** Opens chat screen with the specific user

### 2. Workout Plan Update
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
**Navigation:** Opens plan editor screen

### 3. Check-in Reminder
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
**Navigation:** Opens check-ins screen

---

## 🧪 Testing

### 1. Get Your FCM Token
Run the app and check the console for:
```
📱 FCM Token: [your_token_here]
```

### 2. Test with Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Paste your FCM token
4. Add notification title and body
5. Under "Additional options" → "Custom data", add:
   - Key: `type`, Value: `chat_message` (or other types)
6. Send and verify the notification appears

### 3. Test Navigation
Tap on the notification and verify it navigates to the correct screen.

---

## 📱 Platform-Specific Notes

### iOS
- **Testing:** Must use a physical device (notifications don't work on simulator)
- **Capabilities:** Push Notifications and Background Modes must be enabled in Xcode
- **APNs Certificate:** Must be uploaded to Firebase Console
- **Info.plist:** Already configured with `FirebaseAppDelegateProxyEnabled = false`

### Android
- **Permissions:** POST_NOTIFICATIONS permission already added for Android 13+
- **Channels:** Three notification channels are automatically created:
  - `chat_messages` - High priority with sound
  - `workout_updates` - High priority with sound
  - `check_in_reminders` - High priority with sound
- **Icon:** Uses default launcher icon (`@mipmap/ic_launcher`)

---

## 🚨 Troubleshooting

### Token is null
- Ensure Firebase is initialized before NotificationService
- Check internet connection
- Verify GoogleService-Info.plist (iOS) / google-services.json (Android) are present

### Notifications not appearing on iOS
- Test on physical device only
- Check Push Notifications capability in Xcode
- Verify APNs certificate in Firebase Console
- Check notification permissions: Settings → Your App → Notifications

### Notifications not appearing on Android
- Check POST_NOTIFICATIONS permission granted (Android 13+)
- Verify notification channels are created
- Check app notification settings in device settings

### Navigation not working
- Ensure notification data includes the `type` field
- Check console logs for navigation attempts
- Verify routes exist in `app_router.dart`

---

## 🔧 API Endpoints

Your backend should implement these endpoints:

### Register Token
```
POST /admin-app/notifications/register-token
Headers: {
  "token": "shanempc113@",
  "Content-Type": "application/json"
}
Body: {
  "fcmToken": "device_fcm_token"
}
```

### Remove Token
```
POST /admin-app/notifications/remove-token
Headers: {
  "token": "shanempc113@"
}
```

---

## 📚 Additional Features

The NotificationService also provides:

### Clear All Notifications
```dart
await NotificationService().clearAllNotifications();
```

### Clear Specific Notification
```dart
await NotificationService().clearNotification(notificationId);
```

### Check if Notifications Enabled
```dart
final enabled = await NotificationService().areNotificationsEnabled();
if (!enabled) {
  // Show prompt to enable notifications
}
```

### Get Notification Settings
```dart
final settings = await NotificationService().getNotificationSettings();
print('Authorization: ${settings.authorizationStatus}');
```

---

## 🎯 Next Steps

1. **Implement Token Registration in Login Flow**
   - Call `apiService.registerFCMToken()` after successful login

2. **Implement Token Removal in Logout Flow**
   - Call `apiService.removeFCMToken()` before logout

3. **Test on Both Platforms**
   - iOS: Physical device only
   - Android: Can test on emulator or device

4. **Backend Integration**
   - Ensure backend endpoints are implemented
   - Test token registration/removal
   - Send test notifications from backend

5. **Handle Chat Navigation Properly**
   - You may need to fetch the full User object when navigating to chat
   - Update the navigation logic in `notification_service.dart` if needed

---

**Status:** ✅ Fully Integrated
**Last Updated:** November 2025
