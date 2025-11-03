# Push Notifications Implementation Summary

## What Was Implemented

This document summarizes the push notification system added to the MP Club backend and provides guidance for Flutter frontend integration.

## Backend Changes

### 1. Database Schema Updates

**User Model** (`src/models/User.ts`)

- Added `fcmToken?: string` field to store Firebase Cloud Messaging tokens

### 2. Notification Service Enhancements

**File:** `src/services/notification.ts`

Added comprehensive notification functionality:

- User FCM token management (store, retrieve, remove)
- Generic user notification sending
- Specialized notification functions:
  - `sendChatNotification()` - For new chat messages
  - `sendWorkoutPlanNotification()` - For training plan updates
  - `sendCheckInReminder()` - For check-in reminders
- Bulk notification support
- Automatic token cleanup for invalid/expired tokens
- iOS and Android platform-specific configurations

### 3. API Routes

**File:** `src/routes/notifications.ts`

New endpoints:

- `POST /mobile-app/notifications/register-token` - Register FCM token (authenticated)
- `POST /mobile-app/notifications/remove-token` - Remove FCM token on logout (authenticated)

Integrated into `src/app.ts` under `/mobile-app/notifications` route

### 4. Middleware Updates

**File:** `src/middleware/auth.ts`

- Extended Express Request type to include `user` object
- Modified `verifyToken` to attach decoded user ID to request

### 5. Socket Service Integration

**File:** `src/services/socket.ts`

- Integrated automatic push notifications for chat messages
- Sends notification only when recipient is offline
- Prevents notification spam when user is actively online

## Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (FCM Token)    │
└────────┬────────┘
         │
         │ Register Token
         │ (POST /register-token)
         ▼
┌─────────────────┐
│  Backend API    │
│  (Node.js)      │
└────────┬────────┘
         │
         │ Store in MongoDB
         ▼
┌─────────────────┐      ┌──────────────────┐
│  User Document  │      │  Firebase Admin  │
│  {fcmToken}     │◄────►│  Cloud Messaging │
└─────────────────┘      └────────┬─────────┘
                                  │
                                  │ Send Notification
                                  ▼
                         ┌─────────────────┐
                         │  User Device    │
                         │  (Notification) │
                         └─────────────────┘
```

## Notification Flow

### Registration Flow

1. User logs into Flutter app
2. App requests FCM token from Firebase
3. App sends token to backend via `/register-token` endpoint
4. Backend stores token in User document
5. Backend can now send push notifications to user

### Notification Flow

1. Event occurs (e.g., new message, plan update)
2. Backend checks if user has FCM token
3. Backend sends notification via Firebase Admin SDK
4. Firebase delivers notification to user's device
5. User taps notification → App navigates to relevant screen

### Automatic Features

- **Token refresh handling**: Automatically updates when Firebase refreshes tokens
- **Invalid token cleanup**: Removes expired/invalid tokens from database
- **Offline detection**: Only sends push when user is not actively connected
- **Error handling**: Gracefully handles failures without blocking main flow

## Documentation Files

### For Flutter Team

📱 **FLUTTER_PUSH_NOTIFICATIONS.md** - Comprehensive guide including:

- Firebase setup instructions
- iOS and Android configuration
- Complete Flutter implementation code
- API integration examples
- Notification type handling
- Best practices and troubleshooting

### For Backend Team

🔧 **BACKEND_PUSH_NOTIFICATIONS.md** - Quick reference including:

- API endpoint documentation
- Service function reference
- Integration examples
- Error handling patterns
- Testing guidelines
- Monitoring tips

## Notification Types

| Type                  | Title Example            | Use Case           | Data Fields              |
| --------------------- | ------------------------ | ------------------ | ------------------------ |
| `chat_message`        | "New message from Shane" | New chat messages  | `chatRoomId`, `senderId` |
| `workout_plan_update` | "Training Plan Updated"  | Plan modifications | -                        |
| `check_in_reminder`   | "Time for your Check-in" | Daily reminders    | -                        |

## Quick Start for Frontend

### 1. Add Dependencies

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

### 2. Initialize Firebase

```dart
await Firebase.initializeApp();
await NotificationService().initialize();
```

### 3. Register Token After Login

```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
await apiService.registerFCMToken(fcmToken);
```

### 4. Handle Notifications

```dart
FirebaseMessaging.onMessage.listen((message) {
  // Show notification in foreground
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  // Navigate when notification tapped
});
```

See **FLUTTER_PUSH_NOTIFICATIONS.md** for complete implementation.

## Quick Start for Backend

### Send Chat Notification

```typescript
import { sendChatNotification } from './services/notification';

await sendChatNotification(userId, 'Shane', 'Hey, how are you?', chatRoomId);
```

### Send Plan Update

```typescript
import { sendWorkoutPlanNotification } from './services/notification';

await sendWorkoutPlanNotification(userId);
```

### Send to Admin

```typescript
import { sendNotificationToAdmin } from './services/notification';

await sendNotificationToAdmin(
  'New User Signup',
  `${firstName} ${lastName} joined!`
);
```

See **BACKEND_PUSH_NOTIFICATIONS.md** for complete API reference.

## Testing

### Backend Testing

```bash
# Start server
npm start

# Test token registration (requires auth token)
curl -X POST http://localhost:3000/mobile-app/notifications/register-token \
  -H "Authorization: YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fcmToken": "test_token_here"}'
```

### Frontend Testing

1. Run app on physical device (push notifications don't work on simulators)
2. Login and verify token registration
3. Send test notification from Firebase Console
4. Test foreground, background, and terminated states

## Platform-Specific Notes

### iOS

- Requires APNs certificates in Firebase Console
- Push notifications only work on physical devices
- Requires proper entitlements and capabilities
- Need to handle notification permissions explicitly

### Android

- Requires notification channel setup (Android 8.0+)
- Works on both emulators and devices
- Need POST_NOTIFICATIONS permission (Android 13+)
- Custom notification icon recommended

## Environment Setup

### Required Files

- `firebase_admin.json` - Firebase Admin SDK credentials (backend)
- `google-services.json` - Android Firebase config (Flutter)
- `GoogleService-Info.plist` - iOS Firebase config (Flutter)

### Environment Variables

Already configured in backend - no additional variables needed.

## Security Considerations

✅ **Implemented:**

- FCM token endpoints require authentication
- Tokens stored securely in MongoDB
- Invalid tokens automatically removed
- User can only update their own token

⚠️ **Important:**

- Never expose FCM tokens in logs
- Always validate notification data
- Use HTTPS in production
- Keep Firebase Admin SDK credentials secure

## Monitoring & Logs

The backend logs all notification activities:

```
✅ FCM token stored for user 123abc
📤 Notification sent to user 123abc: New message from Shane
🗑️ Invalid token for user 456def, removing...
⚠️ No FCM token found for user 789ghi
```

## Next Steps

### For Flutter Team

1. Review `FLUTTER_PUSH_NOTIFICATIONS.md`
2. Set up Firebase in Flutter project
3. Implement notification service
4. Test on both iOS and Android devices
5. Integrate with existing auth flow

### For Backend Team

1. Review `BACKEND_PUSH_NOTIFICATIONS.md`
2. Add notification calls to relevant controllers
3. Consider implementing scheduled reminders
4. Monitor notification delivery rates
5. Add analytics if needed

## Support & Resources

- **Flutter Documentation**: See `FLUTTER_PUSH_NOTIFICATIONS.md`
- **Backend Documentation**: See `BACKEND_PUSH_NOTIFICATIONS.md`
- **Firebase Console**: https://console.firebase.google.com/
- **FlutterFire Docs**: https://firebase.flutter.dev/
- **FCM Documentation**: https://firebase.google.com/docs/cloud-messaging

## Future Enhancements

Potential features to add:

- [ ] Notification preferences per user
- [ ] Rich media notifications (images)
- [ ] Action buttons on notifications
- [ ] Scheduled notifications (cron jobs)
- [ ] Notification analytics
- [ ] Multi-device support per user
- [ ] Silent notifications for data sync
- [ ] Notification history in app

---

**Created:** November 2025
**Backend Version:** Node.js + Express + Socket.IO
**Frontend Target:** Flutter with firebase_messaging
**Status:** ✅ Ready for Integration
