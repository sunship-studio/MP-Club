# iOS Info.plist Permissions & Configuration

## Required Permissions for Info.plist

Add these entries to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing entries ... -->

    <!-- ============================================ -->
    <!-- FIREBASE CONFIGURATION -->
    <!-- ============================================ -->

    <!-- Disable Firebase App Delegate Proxy (we handle it manually) -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>

    <!-- ============================================ -->
    <!-- NOTIFICATION PERMISSIONS (iOS 10+) -->
    <!-- ============================================ -->

    <!-- Background Modes for Push Notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
        <string>fetch</string>
    </array>

    <!-- ============================================ -->
    <!-- OPTIONAL: USER-FACING PERMISSION DESCRIPTIONS -->
    <!-- ============================================ -->

    <!-- Notification Permission Description (shown in iOS Settings) -->
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>

    <!-- ============================================ -->
    <!-- OTHER EXISTING PERMISSIONS YOU MAY HAVE -->
    <!-- ============================================ -->

    <!-- Camera (for check-in photos) -->
    <key>NSCameraUsageDescription</key>
    <string>MP Club needs camera access to take check-in photos and progress pictures.</string>

    <!-- Photo Library (for selecting images) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>MP Club needs photo library access to select images for your check-ins.</string>

    <!-- Photo Library Add Only (for saving) -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>MP Club needs permission to save your progress photos.</string>

</dict>
</plist>
```

## Complete Info.plist Example

Here's a complete example with all recommended settings:

```xml

```

## Permission Handler Package

### Do You Need It?

**For Notifications: NO** ❌
- Firebase Messaging handles notification permissions automatically
- Your `NotificationService` already requests permissions via `FirebaseMessaging`

**For Camera/Photos: OPTIONAL** ⚠️
- Your app uses `image_picker` which handles permissions internally
- You can add `permission_handler` for more control, but it's not required

### If You Want More Control (Optional)

If you want to check permissions before showing pickers, add:

```yaml
dependencies:
  permission_handler: ^11.0.1
```

**Example Usage:**

```dart
import 'package:permission_handler/permission_handler.dart';

// Check notification permission status
Future<bool> checkNotificationPermission() async {
  final status = await Permission.notification.status;
  return status.isGranted;
}

// Request notification permission (optional - Firebase already does this)
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.request();
  if (status.isGranted) {
    print('Notification permission granted');
  }
}

// Check camera permission before using image_picker
Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
  return status.isGranted;
}

// Check photo library permission
Future<bool> checkPhotoPermission() async {
  final status = await Permission.photos.status;
  if (status.isDenied) {
    final result = await Permission.photos.request();
    return result.isGranted;
  }
  return status.isGranted;
}
```

## What's Already Handled

### ✅ Notifications (via NotificationService)
```dart
// Already in NotificationService._requestPermissions()
final settings = await _messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
);
```

### ✅ Camera/Photos (via image_picker)
```dart
// image_picker automatically requests permissions
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.camera);
```

## Xcode Configuration (In Addition to Info.plist)

### 1. Open Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Add Capabilities

1. Select **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add:
   - ✅ **Push Notifications**
   - ✅ **Background Modes**
     - Check: "Remote notifications"
     - Check: "Background fetch"

### 3. Verify Settings

**Push Notifications:**
- Should show "Push Notifications" capability card
- No additional configuration needed

**Background Modes:**
- Should show checkmarks for:
  - ✅ Remote notifications
  - ✅ Background fetch

## Testing Permissions

### Test Notification Permission:
```bash
# Run app and check logs
flutter run

# Look for:
✅ User granted notification permission
# or
❌ User declined or has not accepted permission

# If denied, user can enable in:
Settings > MP Club > Notifications
```

### Test Camera/Photo Permission:
```dart
// When user taps camera/photo picker, iOS will show permission dialog
// The image_picker package handles this automatically
```

## Common Permission Issues

### Issue: "Notification permission not requested"
**Solution:** Ensure `Info.plist` has `UIBackgroundModes` and Firebase is initialized

### Issue: "Camera permission not working"
**Solution:** Add `NSCameraUsageDescription` to `Info.plist`

### Issue: "Photo library access denied"
**Solution:** Add `NSPhotoLibraryUsageDescription` to `Info.plist`

### Issue: "Notifications not appearing"
**Solution:**
1. Check notification permissions in iOS Settings
2. Verify Push Notifications capability is enabled in Xcode
3. Test on physical device (simulator doesn't support push)

## Summary

### Required for Notifications:
1. ✅ `FirebaseAppDelegateProxyEnabled` = false
2. ✅ `UIBackgroundModes` with `remote-notification` and `fetch`
3. ✅ Push Notifications capability in Xcode
4. ✅ Background Modes capability in Xcode

### Optional (Already Have):
- `image_picker` package (handles camera/photo permissions)
- Firebase Messaging (handles notification permission requests)

### NOT Required:
- ❌ `permission_handler` package (unless you want more control)
- ❌ Manual permission handling code (Firebase does it)

## Next Steps

1. Add the required entries to `ios/Runner/Info.plist`
2. Open Xcode and add capabilities
3. Test on a physical device
4. Check logs for permission status

That's it! Your notification permissions are already handled by Firebase Messaging. Just add the Info.plist entries and Xcode capabilities! 🚀
