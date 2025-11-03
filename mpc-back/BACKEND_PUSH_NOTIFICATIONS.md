# Backend Push Notifications - Quick Reference

## Overview

This document provides a quick reference for the push notification system implemented in the MP Club backend.

## Architecture

```
User Device (FCM Token) <-> Backend API <-> Firebase Cloud Messaging <-> User Device (Notification)
```

## Database Schema

### User Model

```typescript
{
  fcmToken?: string; // Firebase Cloud Messaging token for push notifications
}
```

### AdminSettings Model

```typescript
{
  key: "admin_fcm_token",  // Shane's FCM token
  value: string
}
```

## API Endpoints

### User Token Management

#### Register FCM Token

```
POST /mobile-app/notifications/register-token
Authorization: Bearer <token>
X-Refresh-Token: <refresh-token>

Body:
{
  "fcmToken": "string"
}

Response:
{
  "message": "FCM token registered successfully",
  "success": true
}
```

#### Remove FCM Token (Logout)

```
POST /mobile-app/notifications/remove-token
Authorization: Bearer <token>
X-Refresh-Token: <refresh-token>

Response:
{
  "message": "FCM token removed successfully",
  "success": true
}
```

### Admin Token Management

#### Save Admin Token

```
POST /mobile-app/notifications/save_token

Body:
{
  "token": "string",
  "debug": boolean  // optional, for debug token
}

Response:
{
  "message": "Token stored successfully"
}
```

## Notification Service API

### Import

```typescript
import {
  // User token management
  storeUserFCMToken,
  getUserFCMToken,
  removeUserFCMToken,
  // User notifications
  sendNotificationToUser,
  sendNotificationToMultipleUsers,
  sendChatNotification,
  sendWorkoutPlanNotification,
  sendCheckInReminder,
  // Admin functions
  storeAdminFCMToken,
  getAdminFCMToken,
  sendNotificationToAdmin,
  sendNotificationToDebug,
} from './services/notification';
```

### User Token Management Functions

#### Store User FCM Token

```typescript
await storeUserFCMToken(userId: string, token: string): Promise<boolean>
```

#### Get User FCM Token

```typescript
const token = await getUserFCMToken(userId: string): Promise<string | null>
```

#### Remove User FCM Token

```typescript
await removeUserFCMToken(userId: string): Promise<boolean>
```

### Sending Notifications

#### Generic User Notification

```typescript
await sendNotificationToUser(
  userId: string,
  payload: {
    title: string;
    body: string;
    data?: { [key: string]: string };
    imageUrl?: string;
  }
): Promise<boolean>
```

#### Chat Notification

```typescript
await sendChatNotification(
  userId: string,
  senderName: string,
  messagePreview: string,
  chatRoomId: string
): Promise<boolean>
```

**Notification Payload:**

```json
{
  "title": "New message from Shane",
  "body": "Message preview...",
  "data": {
    "type": "chat_message",
    "chatRoomId": "user_id",
    "senderId": "Shane"
  }
}
```

#### Workout Plan Update Notification

```typescript
await sendWorkoutPlanNotification(userId: string): Promise<boolean>
```

**Notification Payload:**

```json
{
  "title": "Training Plan Updated",
  "body": "Shane has updated your training plan. Check it out!",
  "data": {
    "type": "workout_plan_update"
  }
}
```

#### Check-in Reminder

```typescript
await sendCheckInReminder(userId: string): Promise<boolean>
```

**Notification Payload:**

```json
{
  "title": "Time for your Check-in",
  "body": "Don't forget to log your progress today!",
  "data": {
    "type": "check_in_reminder"
  }
}
```

#### Bulk Notifications

```typescript
const results = await sendNotificationToMultipleUsers(
  userIds: string[],
  payload: NotificationPayload
): Promise<{ success: number; failed: number }>
```

## Integration Examples

### 1. Socket Service (Chat)

Already integrated! When a message is sent and the recipient is offline:

```typescript
// In socket.ts - handleChatEvents()
if (!isRecipientOnline) {
  const senderName = fromShane ? 'Shane' : 'Client';
  const messagePreview =
    content?.trim().substring(0, 100) || 'Sent an attachment';

  sendChatNotification(
    recipientId,
    senderName,
    messagePreview,
    targetClientId
  ).catch((err) => console.error('Failed to send push notification:', err));
}
```

### 2. Workout Plan Controller

Add to your workout plan update endpoint:

```typescript
import { sendWorkoutPlanNotification } from '../services/notification';

// After updating training plan
await sendWorkoutPlanNotification(userId);
```

### 3. Check-in Controller

For automated reminders (use with a cron job):

```typescript
import { sendCheckInReminder } from '../services/notification';

// Send reminder to users who haven't checked in today
async function sendDailyReminders() {
  const users = await User.find({
    /* logic to find users */
  });

  for (const user of users) {
    await sendCheckInReminder(user._id.toString());
  }
}
```

### 4. Admin Notifications

For notifying Shane about important events:

```typescript
import { sendNotificationToAdmin } from '../services/notification';

// When a user signs up
await sendNotificationToAdmin(
  'New User Signup',
  `${firstName} ${lastName} just signed up!`
);

// When a payment is received
await sendNotificationToAdmin(
  'Payment Received',
  `Payment from ${firstName} ${lastName}: $${amount}`
);
```

## Error Handling

The notification service automatically handles:

- **Invalid tokens**: Removes them from the database
- **Token not found**: Returns `false` without throwing
- **Firebase errors**: Logs and returns `false`

Always use try-catch when calling notification functions:

```typescript
try {
  const success = await sendNotificationToUser(userId, payload);
  if (!success) {
    console.log('Notification not sent (user may not have token)');
  }
} catch (error) {
  console.error('Error sending notification:', error);
  // Don't block the main flow
}
```

## Notification Types Reference

| Type                  | Data Field               | Purpose                     |
| --------------------- | ------------------------ | --------------------------- |
| `chat_message`        | `chatRoomId`, `senderId` | Navigate to chat            |
| `workout_plan_update` | -                        | Navigate to workout plan    |
| `check_in_reminder`   | -                        | Navigate to check-in screen |

## Testing

### Test with Debug Token

```typescript
import { sendNotificationToDebug } from './services/notification';

await sendNotificationToDebug('Test Title', 'Test Body');
```

### Test User Notification

```typescript
// First, register a test device token via the API endpoint
// Then:
await sendNotificationToUser(testUserId, {
  title: 'Test Notification',
  body: 'This is a test',
  data: { test: 'true' },
});
```

### Verify Token Storage

```typescript
const token = await getUserFCMToken(userId);
console.log('User FCM Token:', token);
```

## Best Practices

1. **Always send notifications asynchronously** - Don't block the main flow
2. **Keep message preview short** - Limit to 100-150 characters
3. **Include relevant data** - Help the app navigate correctly
4. **Handle failures gracefully** - Log but don't throw errors
5. **Test on both platforms** - iOS and Android behave differently
6. **Remove tokens on logout** - Prevent sending to inactive devices
7. **Use meaningful notification types** - Makes frontend routing easier

## Monitoring

### Console Logs

The service logs all notification activities:

- `✅ FCM token stored for user {userId}`
- `📤 Notification sent to user {userId}: {title}`
- `🗑️ Invalid token for user {userId}, removing...`
- `⚠️ No FCM token found for user {userId}`

### Check Token Status

```typescript
// In your route or controller
const hasToken = (await getUserFCMToken(userId)) !== null;
console.log(`User ${userId} has FCM token: ${hasToken}`);
```

## Common Issues

### Notifications not received

1. Check if user has registered token: `getUserFCMToken(userId)`
2. Verify Firebase configuration in `firebase_admin.json`
3. Check iOS APNs certificates in Firebase Console
4. Verify Android app is properly configured with google-services.json

### Token not saving

1. Ensure user is authenticated when calling `/register-token`
2. Check userId is valid MongoDB ObjectId
3. Verify User model has `fcmToken` field

### iOS specific issues

- Ensure APNs certificates are uploaded to Firebase
- Check that notification priority and sound are configured
- Verify device has notification permissions enabled

## Future Enhancements

Potential additions:

- Notification preferences per user (enable/disable types)
- Scheduled notifications
- Rich media notifications (images, actions)
- Notification analytics and tracking
- Multi-device support per user
- Silent notifications for data sync

---

**Last Updated:** November 2025
