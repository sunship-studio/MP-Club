# Admin App Documentation - MP Club

## Overview

This documentation provides comprehensive guidance for the MP Club admin application (Shane's side). It covers push notifications, API endpoints, Socket.IO integration, and best practices for managing the platform.

## Table of Contents

1. [Authentication](#authentication)
2. [Push Notifications](#push-notifications)
3. [Chat System](#chat-system)
4. [User Management](#user-management)
5. [API Endpoints](#api-endpoints)
6. [Socket.IO Integration](#socketio-integration)
7. [Best Practices](#best-practices)
8. [Testing](#testing)

---

## Authentication

### Admin Token Authentication

The admin app uses a special token-based authentication system.

#### Headers Required

```javascript
{
  "token": "YOUR_ADMIN_TOKEN" // Set in environment variables
}
```

#### Environment Setup

```bash
ADMIN_TOKEN=your_secure_admin_token_here
```

#### Example Request

```javascript
fetch('https://api.mpclub.com/admin-app/endpoint', {
  headers: {
    token: 'YOUR_ADMIN_TOKEN',
    'Content-Type': 'application/json',
  },
});
```

### Shane's Special Socket Authentication

For Socket.IO connections, Shane uses a special authentication:

```javascript
const socket = io('wss://api.mpclub.com', {
  auth: {
    token: 'shanempc113@', // Special admin token
    userId: 'shane_user_id',
  },
});
```

---

## Push Notifications

### Overview

The admin app can receive and send push notifications to manage client communications and stay updated on platform events.

### Admin FCM Token Registration

#### Endpoint

```
POST /mobile-app/notifications/save_token
```

#### Request Body

```json
{
  "token": "admin_fcm_token_here",
  "debug": false // Set to true for debug token
}
```

#### Response

```json
{
  "message": "Token stored successfully"
}
```

#### Implementation Example

**JavaScript/TypeScript:**

```typescript
async function registerAdminFCMToken(fcmToken: string, isDebug = false) {
  try {
    const response = await fetch(
      'https://api.mpclub.com/mobile-app/notifications/save_token',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: fcmToken,
          debug: isDebug,
        }),
      }
    );

    if (response.ok) {
      console.log('Admin FCM token registered successfully');
      return true;
    }
    return false;
  } catch (error) {
    console.error('Failed to register admin FCM token:', error);
    return false;
  }
}
```

**React Native:**

```javascript
import messaging from '@react-native-firebase/messaging';

async function initializeAdminNotifications() {
  // Request permission
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;

  if (enabled) {
    // Get FCM token
    const fcmToken = await messaging().getToken();

    // Register with backend
    await registerAdminFCMToken(fcmToken);

    // Listen for token refresh
    messaging().onTokenRefresh(async (newToken) => {
      await registerAdminFCMToken(newToken);
    });
  }
}
```

### Admin Notification Types

#### 1. New User Signup Notification

Automatically sent when a new user signs up.

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

#### 2. Payment Received Notification

Sent when a payment is processed.

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

#### 3. New Message Notification

Sent when a client sends a message to Shane.

```json
{
  "notification": {
    "title": "New message from John Doe",
    "body": "Message preview..."
  },
  "data": {
    "type": "chat_message",
    "chatRoomId": "user_id_here",
    "senderId": "user_id_here"
  }
}
```

#### 4. Client Presence Notifications

Sent when clients go online/offline (via Socket.IO).

```json
{
  "clientId": "user_id_here",
  "status": "online",
  "timestamp": "2025-11-03T12:00:00Z"
}
```

### Sending Notifications to Clients

While connected via Socket.IO or making API calls, Shane can trigger notifications to clients.

#### Example: Send Notification After Training Plan Update

```typescript
// After updating a client's training plan
async function updateClientTrainingPlan(userId: string, planData: any) {
  // Update the plan via API
  await fetch(`https://api.mpclub.com/admin-app/update-plan/${userId}`, {
    method: 'POST',
    headers: {
      token: ADMIN_TOKEN,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(planData),
  });

  // Backend automatically sends push notification
  // No additional code needed - handled by backend
  console.log('Training plan updated, notification sent automatically');
}
```

### Handling Incoming Notifications

**React Native Example:**

```javascript
import messaging from '@react-native-firebase/messaging';
import { useNavigation } from '@react-navigation/native';

function useNotificationHandlers() {
  const navigation = useNavigation();

  useEffect(() => {
    // Handle foreground messages
    const unsubscribe = messaging().onMessage(async (remoteMessage) => {
      console.log('Notification received in foreground:', remoteMessage);

      // Show local notification
      // or update UI badge/indicator
    });

    // Handle notification tap (background/killed state)
    messaging().onNotificationOpenedApp((remoteMessage) => {
      handleNotificationNavigation(remoteMessage);
    });

    // Check if app was opened from a notification (killed state)
    messaging()
      .getInitialNotification()
      .then((remoteMessage) => {
        if (remoteMessage) {
          handleNotificationNavigation(remoteMessage);
        }
      });

    return unsubscribe;
  }, []);

  function handleNotificationNavigation(message) {
    const { type, chatRoomId, userId } = message.data;

    switch (type) {
      case 'chat_message':
        navigation.navigate('Chat', { roomId: chatRoomId });
        break;

      case 'new_user':
        navigation.navigate('UserDetails', { userId });
        break;

      case 'payment_received':
        navigation.navigate('Payments', { userId });
        break;

      default:
        navigation.navigate('Dashboard');
    }
  }
}
```

---

## Chat System

### Overview

The chat system uses Socket.IO for real-time communication between Shane and clients. Shane can manage multiple client conversations simultaneously.

### Socket.IO Connection

#### Connection Setup

```javascript
import io from 'socket.io-client';

const socket = io('wss://api.mpclub.com', {
  auth: {
    token: 'shanempc113@', // Special admin token
    userId: 'shane_user_id', // Your admin user ID
  },
  transports: ['websocket', 'polling'],
  reconnection: true,
  reconnectionDelay: 1000,
  reconnectionDelayMax: 5000,
});

// Connection handlers
socket.on('connect', () => {
  console.log('✅ Connected to chat server');
});

socket.on('disconnect', (reason) => {
  console.log('❌ Disconnected:', reason);
});

socket.on('connect_error', (error) => {
  console.error('Connection error:', error);
});
```

### Initial Data

Upon connection, Shane receives initial data including unread message counts:

```javascript
socket.on('initial:data', (data) => {
  console.log('Initial data:', data);
  /*
  {
    unreadCount: { total: 5, perClient: { "client1": 2, "client2": 3 } },
    isUserOnline: false,
    serverTime: "2025-11-03T12:00:00Z",
    connectionId: "socket_id_here"
  }
  */

  // Update UI with unread counts
  updateUnreadBadges(data.unreadCount);
});
```

### Chat Events

#### 1. Sending Messages

```javascript
function sendMessage(
  clientId,
  content,
  messageType = 'text',
  attachment = null
) {
  const idempotencyKey = `msg_${Date.now()}_${Math.random()}`;

  socket.emit(
    'message:send',
    {
      clientId: clientId,
      content: content,
      message_type: messageType,
      attachment: attachment,
      idempotencyKey: idempotencyKey,
    },
    (response) => {
      if (response.success) {
        console.log('Message sent:', response.message);
        // Update UI with sent message
        addMessageToUI(response.message);
      } else {
        console.error('Failed to send message:', response.error);
        // Show error to user
      }
    }
  );
}

// Usage
sendMessage('client_user_id', 'Hey! How are you doing today?');
```

#### 2. Receiving Messages

```javascript
socket.on('message:new', (message) => {
  console.log('New message received:', message);
  /*
  {
    _id: "message_id",
    client_id: "user_id",
    content: "Message text",
    fromShane: false,
    message_type: "text",
    createdAt: "2025-11-03T12:00:00Z",
    read: false
  }
  */

  // Add message to chat UI
  addMessageToChat(message);

  // Play notification sound if appropriate
  if (!message.fromShane && !isCurrentChatOpen(message.client_id)) {
    playNotificationSound();
  }
});
```

#### 3. Loading Message History

```javascript
function loadMessages(clientId, before = null, limit = 50) {
  socket.emit(
    'messages:load',
    {
      clientId: clientId,
      before: before, // Date string or null for latest
      limit: limit,
    },
    (response) => {
      if (response.success) {
        console.log(`Loaded ${response.messages.length} messages`);
        displayMessages(response.messages);

        if (response.hasMore) {
          // Show "Load More" button
          enableLoadMoreButton(clientId, response.messages[0].createdAt);
        }
      } else {
        console.error('Failed to load messages:', response.error);
      }
    }
  );
}

// Load initial messages
loadMessages('client_user_id');

// Load older messages (pagination)
loadMessages('client_user_id', '2025-11-01T00:00:00Z');
```

#### 4. Marking Messages as Read

```javascript
function markMessagesAsRead(clientId, messageIds = []) {
  socket.emit(
    'messages:mark-read',
    {
      clientId: clientId,
      messageIds: messageIds,
    },
    (response) => {
      if (response.success) {
        console.log('Messages marked as read');
        // Update UI to show messages as read
      }
    }
  );
}

// Mark all messages from a client as read when opening chat
socket.on('message:new', (message) => {
  if (isCurrentChatOpen(message.client_id)) {
    markMessagesAsRead(message.client_id, [message._id]);
  }
});
```

#### 5. Typing Indicators

```javascript
let typingTimeout;

function handleTypingStart(clientId) {
  clearTimeout(typingTimeout);

  socket.emit('typing:start', { clientId: clientId });

  // Auto-stop after 3 seconds
  typingTimeout = setTimeout(() => {
    handleTypingStop(clientId);
  }, 3000);
}

function handleTypingStop(clientId) {
  socket.emit('typing:stop', { clientId: clientId });
}

// Receive typing indicators
socket.on('typing:status', (data) => {
  const { clientId, isTyping, fromShane } = data;

  if (!fromShane) {
    // Client is typing
    if (isTyping) {
      showTypingIndicator(clientId);
    } else {
      hideTypingIndicator(clientId);
    }
  }
});

// Usage in input field
const messageInput = document.getElementById('message-input');
messageInput.addEventListener('input', () => {
  handleTypingStart(currentClientId);
});
```

#### 6. Client Presence

Track when clients come online/offline:

```javascript
socket.on('client:presence', (data) => {
  const { clientId, status, timestamp } = data;

  console.log(`Client ${clientId} is now ${status}`);

  // Update UI
  updateClientOnlineStatus(clientId, status === 'online');

  // Update last seen
  if (status === 'offline') {
    updateLastSeen(clientId, timestamp);
  }
});
```

#### 7. Unread Count Updates

```javascript
socket.on('unread:update', (unreadData) => {
  console.log('Unread counts updated:', unreadData);
  /*
  {
    total: 5,
    perClient: {
      "client1": 2,
      "client2": 3
    }
  }
  */

  // Update badges in client list
  updateUnreadBadges(unreadData);
});
```

### Complete Chat Component Example

**React Example:**

```jsx
import React, { useState, useEffect, useRef } from 'react';
import io from 'socket.io-client';

function AdminChat({ clientId }) {
  const [messages, setMessages] = useState([]);
  const [inputValue, setInputValue] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [isClientOnline, setIsClientOnline] = useState(false);
  const socketRef = useRef(null);

  useEffect(() => {
    // Connect to Socket.IO
    socketRef.current = io('wss://api.mpclub.com', {
      auth: {
        token: 'shanempc113@',
        userId: 'shane_user_id',
      },
    });

    const socket = socketRef.current;

    // Connection events
    socket.on('connect', () => {
      console.log('Connected to chat');
      loadMessages();
    });

    // Initial data
    socket.on('initial:data', (data) => {
      setIsClientOnline(data.isUserOnline);
    });

    // New messages
    socket.on('message:new', (message) => {
      if (message.client_id === clientId) {
        setMessages((prev) => [...prev, message]);

        // Mark as read if chat is open
        socket.emit('messages:mark-read', {
          clientId: clientId,
          messageIds: [message._id],
        });
      }
    });

    // Typing indicator
    socket.on('typing:status', (data) => {
      if (data.clientId === clientId && !data.fromShane) {
        setIsTyping(data.isTyping);
      }
    });

    // Client presence
    socket.on('client:presence', (data) => {
      if (data.clientId === clientId) {
        setIsClientOnline(data.status === 'online');
      }
    });

    return () => {
      socket.disconnect();
    };
  }, [clientId]);

  function loadMessages() {
    socketRef.current.emit(
      'messages:load',
      {
        clientId: clientId,
        limit: 50,
      },
      (response) => {
        if (response.success) {
          setMessages(response.messages.reverse());
        }
      }
    );
  }

  function sendMessage() {
    if (!inputValue.trim()) return;

    socketRef.current.emit(
      'message:send',
      {
        clientId: clientId,
        content: inputValue,
        message_type: 'text',
        idempotencyKey: `msg_${Date.now()}`,
      },
      (response) => {
        if (response.success) {
          setMessages((prev) => [...prev, response.message]);
          setInputValue('');
        }
      }
    );
  }

  function handleInputChange(e) {
    setInputValue(e.target.value);

    // Send typing indicator
    if (e.target.value) {
      socketRef.current.emit('typing:start', { clientId });
    } else {
      socketRef.current.emit('typing:stop', { clientId });
    }
  }

  return (
    <div className="chat-container">
      <div className="chat-header">
        <h3>Chat with Client</h3>
        <span className={`status ${isClientOnline ? 'online' : 'offline'}`}>
          {isClientOnline ? 'Online' : 'Offline'}
        </span>
      </div>

      <div className="messages">
        {messages.map((msg) => (
          <div key={msg._id} className={msg.fromShane ? 'sent' : 'received'}>
            <p>{msg.content}</p>
            <small>{new Date(msg.createdAt).toLocaleTimeString()}</small>
          </div>
        ))}
        {isTyping && (
          <div className="typing-indicator">Client is typing...</div>
        )}
      </div>

      <div className="input-area">
        <input
          type="text"
          value={inputValue}
          onChange={handleInputChange}
          onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Type a message..."
        />
        <button onClick={sendMessage}>Send</button>
      </div>
    </div>
  );
}

export default AdminChat;
```

---

## User Management

### Get All Users

```
GET /admin-app/users
Headers: { "token": "ADMIN_TOKEN" }
```

### Get User Details

```
GET /admin-app/users/:userId
Headers: { "token": "ADMIN_TOKEN" }
```

### Update User Training Plan

```
POST /admin-app/users/:userId/training-plan
Headers: { "token": "ADMIN_TOKEN", "Content-Type": "application/json" }

Body:
{
  "trainingPlan": {
    "name": "Advanced Program",
    "days": [
      {
        "name": "Day 1 - Push",
        "exercises": [...]
      }
    ]
  }
}
```

**Note:** After updating a training plan, the backend automatically sends a push notification to the client.

---

## API Endpoints

### Admin App Routes

All admin routes require the admin token in headers.

#### Base URL

```
https://api.mpclub.com/admin-app
```

#### Available Endpoints

| Endpoint                             | Method | Description                                  |
| ------------------------------------ | ------ | -------------------------------------------- |
| `/admin-app/users`                   | GET    | Get all users                                |
| `/admin-app/users/:id`               | GET    | Get user details                             |
| `/admin-app/users/:id`               | PUT    | Update user                                  |
| `/admin-app/users/:id/training-plan` | POST   | Update training plan                         |
| `/admin-app/analytics`               | GET    | Get platform analytics                       |
| `/admin-app/chat/:clientId/messages` | GET    | Get chat messages (alternative to Socket.IO) |

### Notification Routes

| Endpoint                               | Method | Description              |
| -------------------------------------- | ------ | ------------------------ |
| `/mobile-app/notifications/save_token` | POST   | Register admin FCM token |

---

## Best Practices

### 1. Connection Management

- **Maintain single Socket.IO connection** across the app
- **Handle reconnection gracefully** with exponential backoff
- **Store connection instance** in a global state manager (Redux, Context, etc.)
- **Clean up on logout** to prevent memory leaks

### 2. Message Handling

- **Use idempotency keys** to prevent duplicate messages
- **Implement optimistic UI updates** for better UX
- **Cache messages locally** to reduce server load
- **Paginate message history** for better performance

### 3. Notification Management

- **Register FCM token immediately** after login
- **Update token on refresh** to ensure deliverability
- **Handle notification permissions** gracefully
- **Test on physical devices** for accurate behavior

### 4. Error Handling

```javascript
socket.on('connect_error', (error) => {
  console.error('Connection failed:', error);
  // Show user-friendly error message
  showNotification('Connection lost. Retrying...', 'error');
});

socket.on('error', (error) => {
  console.error('Socket error:', error);
  // Handle specific errors
  if (error === 'AUTH_REQUIRED') {
    // Redirect to login
  }
});
```

### 5. Performance

- **Debounce typing indicators** to reduce network traffic
- **Batch read receipts** when marking multiple messages
- **Use React.memo/useMemo** to prevent unnecessary re-renders
- **Implement virtual scrolling** for large message lists

### 6. Security

- **Never expose admin token** in client code
- **Use environment variables** for sensitive data
- **Validate all incoming data** before displaying
- **Sanitize message content** to prevent XSS

---

## Testing

### Testing Socket.IO Connection

```javascript
// test-socket.js
const io = require('socket.io-client');

const socket = io('http://localhost:3000', {
  auth: {
    token: 'shanempc113@',
    userId: 'test_admin_id',
  },
});

socket.on('connect', () => {
  console.log('✅ Connected successfully');

  // Test sending a message
  socket.emit(
    'message:send',
    {
      clientId: 'test_client_id',
      content: 'Test message from admin',
      message_type: 'text',
      idempotencyKey: 'test_key_' + Date.now(),
    },
    (response) => {
      console.log('Message response:', response);
    }
  );
});

socket.on('connect_error', (error) => {
  console.error('❌ Connection failed:', error);
});
```

### Testing Push Notifications

```bash
# Use curl to test FCM token registration
curl -X POST http://localhost:3000/mobile-app/notifications/save_token \
  -H "Content-Type: application/json" \
  -d '{
    "token": "test_fcm_token_here",
    "debug": true
  }'
```

### Testing with Firebase Console

1. Go to Firebase Console
2. Navigate to Cloud Messaging
3. Click "Send test message"
4. Enter your admin FCM token
5. Test different notification types

---

## Troubleshooting

### Common Issues

#### Socket.IO Not Connecting

- **Check server URL** - Ensure correct protocol (ws:// or wss://)
- **Verify admin token** - Must be 'shanempc113@'
- **Check network connectivity** - Firewall/proxy issues
- **Review server logs** - Look for authentication errors

#### Messages Not Sending

- **Verify client ID format** - Must be valid MongoDB ObjectId
- **Check socket connection status** - Must be connected
- **Review callback errors** - Check response.error field
- **Ensure proper data format** - Content must be string

#### Notifications Not Received

- **Verify FCM token registration** - Check database
- **Check Firebase Console** - Verify credentials
- **Test with Firebase test message** - Isolate issue
- **Review device notification settings** - Must be enabled

#### Performance Issues

- **Limit message history** - Use pagination
- **Implement message cleanup** - Remove old messages from memory
- **Optimize re-renders** - Use React optimization techniques
- **Monitor memory usage** - Watch for memory leaks

---

## Additional Resources

- [Socket.IO Client Documentation](https://socket.io/docs/v4/client-api/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [React Native Firebase](https://rnfirebase.io/)
- [Backend API Documentation](./BACKEND_PUSH_NOTIFICATIONS.md)

---

## Support

For technical issues or questions:

1. Review this documentation thoroughly
2. Check backend logs for errors
3. Test with provided examples
4. Contact backend team for API issues

---

**Last Updated:** November 2025
**Version:** 1.0.0
**Target Platform:** Admin Web/Mobile App
