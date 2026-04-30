# Firebase Push Notifications - Setup Instructions

## Overview

Firebase Cloud Messaging (FCM) has been integrated into your MP Club Flutter app. This document provides instructions for completing the platform-specific configuration.

## ✅ Already Implemented

### Code Integration (Complete)

- ✅ Firebase dependencies added to `pubspec.yaml`
- ✅ `NotificationService` created with full FCM handling
- ✅ Notification service registered in dependency injection
- ✅ Firebase initialized in `main.dart`
- ✅ FCM token registration methods added to `DioClient`
- ✅ Socket service automatically registers FCM token on connection
- ✅ Chat screen ready for notification-driven updates
- ✅ Navigation handling for notification taps

## 🔧 Required Platform Configuration

### 1. Firebase Project Setup

1. **Go to [Firebase Console](https://console.firebase.google.com/)**
2. **Select or create your MP Club project**
3. **Enable Cloud Messaging:**
   - Go to Project Settings > Cloud Messaging
   - Ensure FCM API is enabled

### 2. iOS Configuration

#### A. Add GoogleService-Info.plist

1. In Firebase Console, add an iOS app (if not already done)
2. Download `GoogleService-Info.plist`
3. Add it to `ios/Runner/` directory
4. Open `ios/Runner.xcworkspace` in Xcode
5. Add the file to the Runner target (right-click project > Add Files to "Runner")

#### B. Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** and add:
   - **Push Notifications**
   - **Background Modes** (enable "Remote notifications" and "Background fetch")

#### C. Update AppDelegate.swift

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
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

#### D. Configure Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

#### E. APNs Configuration (Production)

For production builds, you need to:

1. Create APNs certificates in Apple Developer Portal
2. Upload them to Firebase Console (Project Settings > Cloud Messaging > iOS App Configuration)

### 3. Android Configuration

#### A. Add google-services.json

1. In Firebase Console, add an Android app (if not already done)
2. Download `google-services.json`
3. Place it in `android/app/` directory

#### B. Update build.gradle Files

**`android/build.gradle.kts`:**

Add to the `dependencies` block inside `buildscript`:

```kotlin
buildscript {
    dependencies {
        // Add this line
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**`android/app/build.gradle.kts`:**

Add at the **bottom** of the file:

```kotlin
// Add this line at the very end
apply(plugin = "com.google.gms.google-services")
```

Also ensure `minSdkVersion` is at least 21:

```kotlin
android {
    defaultConfig {
        minSdk = 21  // FCM requires minimum API 21
    }
}
```

#### C. Add Android Permissions

In `android/app/src/main/AndroidManifest.xml`, add these permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Optional: Add notification icon for better branding -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />

        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
    </application>
</manifest>
```

## 📱 How It Works

### Notification Types

The app handles three types of notifications:

1. **Chat Message Notification**

   - Automatically navigates to chat screen
   - Syncs with socket for real-time updates

2. **Workout Plan Update**

   - Navigates to training plan screen

3. **Check-in Reminder**
   - Navigates to check-in submission screen

### Automatic FCM Token Registration

The app automatically:

1. Requests notification permissions on startup
2. Gets FCM token from Firebase
3. Registers token with backend when socket connects
4. Re-registers token if it refreshes
5. Removes token on logout (when implemented)

### Backend Integration

FCM tokens are sent to:

- **Register:** `POST /mobile-app/notifications/register-token`
- **Remove:** `POST /mobile-app/notifications/remove-token`

Both endpoints require authentication headers:

- `Authorization`: Access token
- `x-refresh-token`: Refresh token

## 🧪 Testing

### Test Notifications from Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter a title and body
4. Click "Send test message"
5. Enter your FCM token (check logs for token)
6. Send the notification

### Test Notification Data Payloads

For chat messages:

```json
{
  "notification": {
    "title": "New message from Shane",
    "body": "Check out the latest update!"
  },
  "data": {
    "type": "chat_message",
    "chatRoomId": "USER_ID_HERE",
    "senderId": "Shane"
  }
}
```

## 🐛 Troubleshooting

### iOS Issues

**Notifications not appearing:**

- Check that Push Notifications capability is enabled
- Verify APNs certificate is valid in Firebase Console
- Check device notification settings
- Ensure app has notification permissions

**Build errors:**

- Run `cd ios && pod install && cd ..`
- Clean build: `flutter clean && flutter pub get`
- Verify GoogleService-Info.plist is in the correct location

### Android Issues

**Notifications not appearing:**

- Verify notification channel is created (automatic in our implementation)
- Check app notification permissions in device settings
- Ensure google-services.json is in `android/app/`

**Build errors:**

- Run `flutter clean && flutter pub get`
- Ensure Google Services plugin is applied at the END of build.gradle
- Check minSdkVersion is at least 21

### General Issues

**FCM token is null:**

- Ensure Firebase is initialized before accessing token
- Check internet connection
- Verify Firebase configuration files are correct

**Backend not receiving token:**

- Check auth token is valid
- Verify API endpoint URL matches your backend
- Check logs for registration errors

## 📋 Next Steps

1. **Add firebase_options.dart (if needed):**

   ```bash
   flutterfire configure
   ```

   This will automatically generate platform configurations.

2. **Test on physical devices:**

   - iOS: Need physical device (simulator doesn't support push)
   - Android: Can test on emulator or physical device

3. **Implement logout FCM token removal:**
   Add to your logout flow:

   ```dart
   await getIt<NotificationService>().removeToken();
   ```

4. **Production setup:**
   - Configure APNs certificates for iOS
   - Test with production build
   - Verify server key in Firebase Console

## 📚 Resources

- [Firebase Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [APNs Configuration](https://firebase.google.com/docs/cloud-messaging/ios/certs)

## 🔔 Notification Behavior

### Foreground (App Open)

- Shows local notification with sound/vibration
- Updates chat UI in real-time via socket
- User can tap notification to navigate

### Background (App Minimized)

- System shows notification
- Tapping opens app and navigates to relevant screen

### Terminated (App Closed)

- System shows notification
- Tapping launches app and navigates to relevant screen

## ✨ Features Implemented

- ✅ Foreground, background, and terminated state handling
- ✅ Automatic token registration and refresh
- ✅ Deep linking to relevant screens
- ✅ Integration with socket service for real-time updates
- ✅ Proper navigation context management
- ✅ Local notifications for foreground messages
- ✅ Android notification channels
- ✅ iOS notification permissions

---

**Need help?** Check the troubleshooting section or refer to Firebase documentation.
