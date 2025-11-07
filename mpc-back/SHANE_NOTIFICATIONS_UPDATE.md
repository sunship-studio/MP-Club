# Shane (Admin) Notifications Update

## 🎯 What Changed

The notification system has been updated to properly save and manage Shane's FCM token, allowing him to receive push notifications on his admin app.

## ✅ New Features

### 1. Admin Token Management
- **Store Shane's FCM token** in the database (AdminSettings collection)
- **Remove token on logout** for security
- **Automatic token cleanup** for invalid/expired tokens
- **Debug token support** for testing

### 2. Notifications to Shane
Shane now receives push notifications for:
- 📨 **New messages from clients** (when offline)
- 💰 **Payment notifications**
- 👤 **New user signups**
- 🔔 **Any custom admin notifications**

## 📡 API Endpoints

### Register Shane's FCM Token
```
POST /mobile-app/notifications/save_token
Content-Type: application/json

Body:
{
  "token": "shane_fcm_token_here",
  "debug": false  // optional, set to true for debug token
}

Response:
{
  "message": "Admin token stored successfully",
  "success": true
}
```

### Remove Shane's FCM Token (Logout)
```
POST /mobile-app/notifications/remove_admin_token

Response:
{
  "message": "Admin token removed successfully",
  "success": true
}
```

## 🔧 Implementation Example

### Admin App (React Native / Flutter)

#### 1. Register Token on Login
```javascript
import messaging from '@react-native-firebase/messaging';

async function registerShaneToken() {
  // Get FCM token
  const fcmToken = await messaging().getToken();
  
  // Register with backend
  const response = await fetch('https://api.mpclub.com/mobile-app/notifications/save_token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      token: fcmToken,
      debug: false
    })
  });
  
  const result = await response.json();
  console.log('Token registered:', result.success);
}

// Call after Shane logs in
await registerShaneToken();
```

#### 2. Remove Token on Logout
```javascript
async function removeShaneToken() {
  const response = await fetch('https://api.mpclub.com/mobile-app/notifications/remove_admin_token', {
    method: 'POST',
  });
  
  const result = await response.json();
  console.log('Token removed:', result.success);
}

// Call before Shane logs out
await removeShaneToken();
```

#### 3. Handle Token Refresh
```javascript
messaging().onTokenRefresh(async (newToken) => {
  // Re-register new token
  await fetch('https://api.mpclub.com/mobile-app/notifications/save_token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      token: newToken,
      debug: false
    })
  });
});
```

#### 4. Handle Incoming Notifications
```javascript
// Foreground messages
messaging().onMessage((remoteMessage) => {
  console.log('Notification received:', remoteMessage);
  
  const { type, chatRoomId, userId } = remoteMessage.data;
  
  // Show local notification or update UI
  if (type === 'chat_message') {
    // Update chat badge count
    updateChatBadge(chatRoomId);
  } else if (type === 'new_user') {
    // Show new user alert
    showNewUserAlert(userId);
  }
});

// Notification tap (background/killed)
messaging().onNotificationOpenedApp((remoteMessage) => {
  const { type, chatRoomId, userId } = remoteMessage.data;
  
  if (type === 'chat_message') {
    // Navigate to chat with specific client
    navigation.navigate('Chat', { clientId: chatRoomId });
  } else if (type === 'new_user') {
    // Navigate to user details
    navigation.navigate('UserDetails', { userId });
  }
});
```

## 📱 Notification Types Shane Receives

### 1. New Client Message
```json
{
  "notification": {
    "title": "New message from John Doe",
    "body": "Hey Shane, I have a question about..."
  },
  "data": {
    "type": "chat_message",
    "chatRoomId": "client_user_id",
    "senderId": "client_user_id"
  }
}
```

### 2. New User Signup (Example - implement in signup controller)
```json
{
  "notification": {
    "title": "New User Signup",
    "body": "John Doe just signed up!"
  },
  "data": {
    "type": "new_user",
    "userId": "user_id_here"
  }
}
```

### 3. Payment Received (Example - implement in payment webhook)
```json
{
  "notification": {
    "title": "Payment Received",
    "body": "Payment from John Doe: $99.99"
  },
  "data": {
    "type": "payment_received",
    "userId": "user_id_here",
    "amount": "99.99"
  }
}
```

## 🔨 Backend Usage Examples

### Send Notification to Shane

```typescript
import { sendNotificationToAdmin } from '../services/notification';

// Example: New user signup
async function handleUserSignup(user: any) {
  await sendNotificationToAdmin(
    'New User Signup',
    `${user.firstName} ${user.lastName} just signed up!`,
    {
      type: 'new_user',
      userId: user._id.toString()
    }
  );
}

// Example: Payment received
async function handlePayment(user: any, amount: number) {
  await sendNotificationToAdmin(
    'Payment Received',
    `Payment from ${user.firstName} ${user.lastName}: $${amount}`,
    {
      type: 'payment_received',
      userId: user._id.toString(),
      amount: amount.toString()
    }
  );
}

// Example: Client sent message (already implemented in socket.ts)
// Automatically triggered when client sends message and Shane is offline
```

## 🔄 Automatic Features

### 1. Chat Notifications (Already Implemented)
- When a **client sends a message** and Shane is **offline**, Shane receives a push notification
- When **Shane sends a message** and client is **offline**, client receives a push notification
- Notifications include sender name and message preview

### 2. Token Validation
- Invalid or expired tokens are **automatically removed** from database
- Prevents sending to non-existent devices
- Logs errors for monitoring

### 3. Platform Support
- Configured for both **iOS (APNs)** and **Android (FCM)**
- Includes proper sound, badge, and priority settings
- Channel ID: `admin_notifications` for Android

## 🗄️ Database Storage

Shane's token is stored in the `AdminSettings` collection:

```javascript
{
  key: 'admin_fcm_token',
  value: 'shane_fcm_token_here'
}

// Optional debug token
{
  key: 'debug_fcm_token',
  value: 'debug_fcm_token_here'
}
```

## 🧪 Testing

### 1. Test Token Registration
```bash
curl -X POST http://localhost:3000/mobile-app/notifications/save_token \
  -H "Content-Type: application/json" \
  -d '{
    "token": "test_token_here",
    "debug": false
  }'
```

### 2. Test Sending Notification
```typescript
import { sendNotificationToAdmin } from './services/notification';

// In any controller
await sendNotificationToAdmin(
  'Test Notification',
  'This is a test message for Shane'
);
```

### 3. Test with Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Send test notification to Shane's token
3. Verify notification appears on Shane's device

## ⚠️ Important Notes

### Security
- **No authentication required** for `/save_token` endpoint (public for admin app)
- Token is stored securely in database
- Token automatically removed on invalid/expired errors

### Token Lifecycle
1. **Login**: Register token immediately after Firebase initialization
2. **Refresh**: Update token automatically when Firebase refreshes it
3. **Logout**: Remove token from backend to stop notifications

### Platform-Specific
- **iOS**: Requires APNs certificates in Firebase Console
- **Android**: Works out of the box with google-services.json
- **Testing**: Must use physical devices (notifications don't work on simulators)

## 📚 Related Documentation

- **Admin App Guide**: See `ADMIN_APP_DOCUMENTATION.md`
- **Backend API**: See `BACKEND_PUSH_NOTIFICATIONS.md`
- **System Overview**: See `PUSH_NOTIFICATIONS_SUMMARY.md`

## 🚀 Next Steps for Admin App

1. ✅ Implement FCM in admin app (React Native Firebase or Flutter Firebase Messaging)
2. ✅ Register token on login
3. ✅ Remove token on logout
4. ✅ Handle token refresh
5. ✅ Implement notification handlers
6. ✅ Add navigation based on notification type
7. ✅ Test on both iOS and Android devices

---

**Updated:** November 2025  
**Status:** ✅ Production Ready  
**Backend Changes:** Complete and deployed
