# 🚀 Quick Start - Push Notifications

## ⚠️ IMPORTANT: Complete These Steps Now

### 1. iOS Setup (Required)

```bash
# 1. Download GoogleService-Info.plist from Firebase Console
# 2. Place in: ios/Runner/GoogleService-Info.plist
# 3. Open Xcode:
open ios/Runner.xcworkspace

# 4. In Xcode:
#    - Add GoogleService-Info.plist to Runner target
#    - Enable "Push Notifications" capability
#    - Enable "Background Modes" > "Remote notifications"
```

**Update ios/Runner/AppDelegate.swift:**

```swift
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self
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

### 2. Android Setup (Required)

```bash
# 1. Download google-services.json from Firebase Console
# 2. Place in: android/app/google-services.json
```

**Update android/build.gradle.kts:**

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")  // ADD THIS
    }
}
```

**Update android/app/build.gradle.kts (at the END):**

```kotlin
apply(plugin = "com.google.gms.google-services")  // ADD THIS AT THE VERY END
```

**Update android/app/src/main/AndroidManifest.xml:**

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 3. Test It

```bash
# Run the app
flutter run

# Look for this in logs:
# ✅ FCM Token: <your-token>
# ✅ FCM token registered with backend

# Test from Firebase Console:
# 1. Go to Cloud Messaging > Send test message
# 2. Paste your FCM token
# 3. Send notification
```

## 🔔 It's Working When You See:

### In Logs:

```
✅ FCM Token: eyJhbGc...
✅ Socket connected
📤 Registering FCM token with backend...
✅ FCM token registered successfully
```

### On Device:

- Notification appears when app is in background
- Tapping notification opens app to correct screen
- Chat updates automatically when receiving message notification

## 🐛 Quick Troubleshooting

| Problem               | Solution                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------- |
| No FCM token in logs  | 1. Check internet<br>2. Verify Firebase files are added<br>3. Restart app                   |
| iOS: No notifications | 1. Test on physical device (not simulator)<br>2. Check notification permissions in Settings |
| Android: Build error  | 1. Ensure `google-services` plugin is at END of build.gradle<br>2. Run `flutter clean`      |
| Backend error 404     | Check that backend endpoints exist:<br>`/mobile-app/notifications/register-token`           |

## 📖 Full Documentation

- **Complete Setup:** `PUSH_NOTIFICATIONS_SETUP.md`
- **Summary:** `NOTIFICATION_INTEGRATION_SUMMARY.md`
- **Code Examples:** `lib/services/fcm_logout_example.dart`

## ✅ Checklist

- [ ] Added GoogleService-Info.plist (iOS)
- [ ] Updated AppDelegate.swift (iOS)
- [ ] Enabled Push Notifications in Xcode (iOS)
- [ ] Added google-services.json (Android)
- [ ] Updated build.gradle files (Android)
- [ ] Added notification permissions (Android)
- [ ] Tested on physical device
- [ ] Confirmed token registration in logs
- [ ] Tested notification tap navigation
- [ ] Backend endpoints working

## 🎯 What's Already Done

✅ All Dart/Flutter code implemented
✅ Dependency injection configured
✅ Socket integration complete
✅ Navigation handling ready
✅ API methods created

**You only need to add the Firebase config files and platform settings!**

---

**Need help?** See `PUSH_NOTIFICATIONS_SETUP.md` for detailed instructions.
