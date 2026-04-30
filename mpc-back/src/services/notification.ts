import firebaseAdmin from '../config/admin';
import AdminSettings from '../models/AdminSettings';
import User from '../models/User';

// ========================================
// ADMIN FCM TOKEN MANAGEMENT
// ========================================

/**
 * Store or update FCM token for Shane (admin)
 * @param token - FCM token from Shane's device
 * @param debug - Optional flag to store in debug token
 */
async function storeAdminFCMToken(token: string, debug: boolean = false) {
  try {
    if (debug) {
      await AdminSettings.findOneAndUpdate(
        { key: 'debug_fcm_token' },
        { value: token },
        { upsert: true, new: true }
      );
      console.log('✅ Debug FCM token stored for admin');
    }

    // Upsert the token (update if exists, insert if doesn't)
    await AdminSettings.findOneAndUpdate(
      { key: 'admin_fcm_token' },
      { value: token },
      { upsert: true, new: true }
    );
    console.log('✅ FCM token stored for admin (Shane)');
    return true;
  } catch (error) {
    console.error('Error storing admin FCM token:', error);
    throw error;
  }
}

/**
 * Get FCM token for Shane (admin)
 */
async function getAdminFCMToken(): Promise<string | null> {
  try {
    const setting = await AdminSettings.findOne({ key: 'admin_fcm_token' });
    return setting ? setting.value : null;
  } catch (error) {
    console.error('Error retrieving admin FCM token:', error);
    throw error;
  }
}

/**
 * Remove admin FCM token (on Shane's logout)
 */
async function removeAdminFCMToken(): Promise<boolean> {
  try {
    await AdminSettings.findOneAndDelete({ key: 'admin_fcm_token' });
    console.log('🗑️ FCM token removed for admin (Shane)');
    return true;
  } catch (error) {
    console.error('Error removing admin FCM token:', error);
    throw error;
  }
}

/**
 * Send push notification to Shane (admin)
 * @param title - Notification title
 * @param body - Notification body
 * @param data - Optional additional data
 */
async function sendNotificationToAdmin(
  title: string,
  body: string,
  data?: { [key: string]: string }
): Promise<boolean> {
  try {
    const adminFCMToken = await getAdminFCMToken();

    if (!adminFCMToken) {
      console.log('⚠️ No FCM token found for admin (Shane)');
      return false;
    }

    await firebaseAdmin.messaging().send({
      token: adminFCMToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        title: title,
        body: body,
        ...data,
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
          channelId: 'admin_notifications',
        },
      },
    });

    console.log(`📤 Notification sent to admin (Shane): ${title} - ${body}`);
    return true;
  } catch (error: any) {
    // Handle invalid token errors
    if (
      error.code === 'messaging/invalid-registration-token' ||
      error.code === 'messaging/registration-token-not-registered'
    ) {
      console.log('🗑️ Invalid admin token, removing...');
      await removeAdminFCMToken();
    } else if (error.code === 'messaging/third-party-auth-error') {
      console.error('⚠️ APNs/FCM Auth Error for admin (Shane):');
      console.error(
        '   → This is likely an APNs certificate/key issue in Firebase Console'
      );
      console.error(
        '   → Check: Firebase Console → Project Settings → Cloud Messaging'
      );
      console.error('   → Ensure APNs Authentication Key is uploaded for iOS');
      console.error(
        '   → For production iOS apps, upload APNs Auth Key (.p8 file)'
      );
    } else {
      console.error(
        '❌ Error sending notification to admin:',
        error.code || error.message
      );
    }
    return false;
  }
}

/**
 * Send notification to debug token (for testing)
 * @param title - Notification title
 * @param body - Notification body
 */
async function sendNotificationToDebug(
  title: string,
  body: string,
  data?: { [key: string]: string }
): Promise<boolean> {
  try {
    const debugFCMToken = await AdminSettings.findOne({
      key: 'debug_fcm_token',
    });

    if (!debugFCMToken?.value) {
      console.log('⚠️ No debug FCM token found');
      return false;
    }

    await firebaseAdmin.messaging().send({
      token: debugFCMToken.value,
      notification: {
        title: title,
        body: body,
      },
      data: {
        title: title,
        body: body,
        ...data,
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
        },
      },
    });

    console.log(`📤 Debug notification sent: ${title}`);
    return true;
  } catch (error) {
    console.error('Error sending debug notification:', error);
    return false;
  }
}

// ========================================
// USER FCM TOKEN MANAGEMENT
// ========================================

/**
 * Store or update FCM token for a specific user
 * @param userId - User's MongoDB ObjectId
 * @param token - FCM token from the device
 */
async function storeUserFCMToken(
  userId: string,
  token: string
): Promise<boolean> {
  try {
    await User.findByIdAndUpdate(userId, { fcmToken: token }, { new: true });
    console.log(`✅ FCM token stored for user ${userId}`);
    return true;
  } catch (error) {
    console.error('Error storing user FCM token:', error);
    throw error;
  }
}

/**
 * Get FCM token for a specific user
 * @param userId - User's MongoDB ObjectId
 */
async function getUserFCMToken(userId: string): Promise<string | null> {
  try {
    const user = await User.findById(userId).select('fcmToken');
    return user?.fcmToken || null;
  } catch (error) {
    console.error('Error retrieving user FCM token:', error);
    throw error;
  }
}

/**
 * Remove FCM token for a user (e.g., on logout)
 * @param userId - User's MongoDB ObjectId
 */
async function removeUserFCMToken(userId: string): Promise<boolean> {
  try {
    await User.findByIdAndUpdate(
      userId,
      { $unset: { fcmToken: '' } },
      { new: true }
    );
    console.log(`🗑️ FCM token removed for user ${userId}`);
    return true;
  } catch (error) {
    console.error('Error removing user FCM token:', error);
    throw error;
  }
}

// ========================================
// USER PUSH NOTIFICATIONS
// ========================================

interface NotificationPayload {
  title: string;
  body: string;
  data?: { [key: string]: string };
  imageUrl?: string;
}

/**
 * Send push notification to a specific user
 * @param userId - User's MongoDB ObjectId
 * @param payload - Notification content
 */
async function sendNotificationToUser(
  userId: string,
  payload: NotificationPayload
): Promise<boolean> {
  try {
    const userFCMToken = await getUserFCMToken(userId);

    if (!userFCMToken) {
      console.log(`⚠️ No FCM token found for user ${userId}`);
      return false;
    }

    const message: any = {
      token: userFCMToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        title: payload.title,
        body: payload.body,
        ...payload.data,
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
          channelId: 'chat_messages',
        },
      },
    };

    if (payload.imageUrl) {
      message.notification.imageUrl = payload.imageUrl;
    }

    await firebaseAdmin.messaging().send(message);
    console.log(`📤 Notification sent to user ${userId}: ${payload.title}`);
    return true;
  } catch (error: any) {
    // Handle invalid token errors
    if (
      error.code === 'messaging/invalid-registration-token' ||
      error.code === 'messaging/registration-token-not-registered'
    ) {
      console.log(`🗑️ Invalid token for user ${userId}, removing...`);
      await removeUserFCMToken(userId);
    } else if (error.code === 'messaging/third-party-auth-error') {
      console.error(`⚠️ APNs/FCM Auth Error for user ${userId}:`);
      console.error(
        '   → This is likely an APNs certificate/key issue in Firebdase Console'
      );
      console.error(
        '   → Check: Firebase Console → Project Settings → Cloud Messaging → APNs Certificates'
      );
      console.error(
        '   → For iOS: Ensure APNs Authentication Key or Certificate is uploaded'
      );
      console.error(
        '   → For Android: This error is rare, check FCM server key'
      );
    } else {
      console.error(
        `❌ Error sending notification to user ${userId}:`,
        error.code || error.message
      );
    }
    return false;
  }
}

/**
 * Send push notification to multiple users
 * @param userIds - Array of user MongoDB ObjectIds
 * @param payload - Notification content
 */
async function sendNotificationToMultipleUsers(
  userIds: string[],
  payload: NotificationPayload
): Promise<{ success: number; failed: number }> {
  const results = await Promise.allSettled(
    userIds.map((userId) => sendNotificationToUser(userId, payload))
  );

  const success = results.filter(
    (r) => r.status === 'fulfilled' && r.value
  ).length;
  const failed = results.length - success;

  console.log(
    `📊 Bulk notification results: ${success} success, ${failed} failed`
  );
  return { success, failed };
}

/**
 * Send notification about new chat message
 */
async function sendChatNotification(
  userId: string,
  senderName: string,
  messagePreview: string,
  chatRoomId: string
): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: `New message from ${senderName}`,
    body: messagePreview,
    data: {
      type: 'chat_message',
      chatRoomId,
      senderId: senderName,
    },
  });
}

/**
 * Send notification to Shane about new client message
 */
async function sendChatNotificationToAdmin(
  clientName: string,
  messagePreview: string,
  clientId: string
): Promise<boolean> {
  return sendNotificationToAdmin(
    `New message from ${clientName}`,
    messagePreview,
    {
      type: 'chat_message',
      chatRoomId: clientId,
      senderId: clientId,
    }
  );
}

/**
 * Send notification about workout plan update
 */
async function sendWorkoutPlanNotification(userId: string): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: 'Training Plan Updated',
    body: 'Shane has updated your training plan. Check it out!',
    data: {
      type: 'workout_plan_update',
    },
  });
}

/**
 * Send notification about check-in reminder
 */
async function sendCheckInReminder(userId: string): Promise<boolean> {
  return sendNotificationToUser(userId, {
    title: 'Time for your Check-in',
    body: "Don't forget to log your progress today!",
    data: {
      type: 'check_in_reminder',
    },
  });
}

export {
  getAdminFCMToken,
  getUserFCMToken,
  removeAdminFCMToken,
  removeUserFCMToken,
  sendChatNotification,
  sendChatNotificationToAdmin,
  sendCheckInReminder,
  // Admin notifications
  sendNotificationToAdmin,
  sendNotificationToDebug,
  sendNotificationToMultipleUsers,
  // User notifications
  sendNotificationToUser,
  sendWorkoutPlanNotification,
  // Admin (Shane) token management
  storeAdminFCMToken,
  // User token management
  storeUserFCMToken,
};
