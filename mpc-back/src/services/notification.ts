import firebaseAdmin from "../config/admin";
import AdminSettings from "../models/AdminSettings";

// Storing or updating the FCM token
async function storeAdminFCMToken(token: string, debug: boolean) {
  if (debug) {
    await AdminSettings.findOneAndUpdate(
      { key: "debug_fcm_token" },
      { value: token },
      { upsert: true, new: true }
    );
  }
  try {
    // Upsert the token (update if exists, insert if doesn't)
    await AdminSettings.findOneAndUpdate(
      { key: "admin_fcm_token" },
      { value: token },
      { upsert: true, new: true }
    );
    return true;
  } catch (error) {
    console.error("Error storing admin FCM token:", error);
    throw error;
  }
}

// Retrieving the token when needed
async function getAdminFCMToken() {
  try {
    const setting = await AdminSettings.findOne({ key: "admin_fcm_token" });
    return setting ? setting.value : null;
  } catch (error) {
    console.error("Error retrieving admin FCM token:", error);
    throw error;
  }
}

async function sendNotificationToAdmin(title: string, body: string) {
  const adminFCMToken = await getAdminFCMToken();
  if (adminFCMToken) {
    firebaseAdmin.messaging().send({
      token: adminFCMToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        title: title,
        body: body,
      },
    });
    console.log(`Sending notification to admin: ${title} - ${body}`);
  } else {
    console.error("No FCM token found for admin.");
  }
}

async function sendNotificationToDebug(
  title: string,
  body: string,
) {
  const debugFCMToken = "fozeAy38bk6LgLmLDuqt-I:APA91bEsA56_HAN2FZNuvvMrStvlFtt5Raq-bfFbxnavya01OXPRRm2UUFUchA1xBOlSsz0XYCwnFVwbeh6dW_jndgHFi8vdYvIdfcog7Jcai7kcaTelQkA";
  firebaseAdmin.messaging().send({
    token: debugFCMToken,
    notification: {
      title: title,
      body: body,
    },
    data: {
      title: title,
      body: body,
    },
    apns: {
      headers: {
        'apns-priority': '10'
      },
      payload: {
        aps: {
          sound: 'default'
        }
      }
    }
  });
}
export { storeAdminFCMToken, getAdminFCMToken, sendNotificationToAdmin, sendNotificationToDebug };
