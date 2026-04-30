// // notification_service.dart - Quick Start Example
// //
// // ⚠️ NOTE: This is a Dart file for Flutter projects
// // Copy this to your Flutter project at: lib/services/notification_service.dart
// // This file will have errors in this TypeScript project - that's expected!
// //
// // This is a ready-to-use implementation example for Flutter developers

// import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // Top-level background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Background message: ${message.messageId}');
// }

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   String? _fcmToken;
//   String? get fcmToken => _fcmToken;

//   /// Initialize notifications - Call this in main()
//   Future<void> initialize() async {
//     // Request permissions
//     await _requestPermissions();

//     // Configure local notifications
//     await _configureLocalNotifications();

//     // Get FCM token
//     _fcmToken = await _messaging.getToken();
//     print('📱 FCM Token: $_fcmToken');

//     // Listen for token refresh
//     _messaging.onTokenRefresh.listen((newToken) {
//       _fcmToken = newToken;
//       // TODO: Update token on backend
//       print('🔄 Token refreshed: $newToken');
//     });

//     // Set up message handlers
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

//     // Check initial message
//     final initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleNotificationTap(initialMessage);
//     }
//   }

//   Future<void> _requestPermissions() async {
//     final settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print('Permission status: ${settings.authorizationStatus}');
//   }

//   Future<void> _configureLocalNotifications() async {
//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );

//     await _localNotifications.initialize(
//       const InitializationSettings(android: androidSettings, iOS: iosSettings),
//       onDidReceiveNotificationResponse: (details) {
//         if (details.payload != null) {
//           final data = jsonDecode(details.payload!);
//           _navigateFromNotification(data);
//         }
//       },
//     );

//     // Android notification channel
//     const channel = AndroidNotificationChannel(
//       'chat_messages',
//       'Chat Messages',
//       description: 'Notifications for new messages',
//       importance: Importance.high,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//   }

//   Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     print('📬 Foreground message: ${message.notification?.title}');

//     if (message.notification != null) {
//       await _localNotifications.show(
//         message.notification.hashCode,
//         message.notification!.title,
//         message.notification!.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'chat_messages',
//             'Chat Messages',
//             importance: Importance.high,
//             priority: Priority.high,
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: jsonEncode(message.data),
//       );
//     }
//   }

//   void _handleNotificationTap(RemoteMessage message) {
//     print('🔔 Notification tapped: ${message.data}');
//     _navigateFromNotification(message.data);
//   }

//   void _navigateFromNotification(Map<String, dynamic> data) {
//     final type = data['type'];

//     switch (type) {
//       case 'chat_message':
//         final chatRoomId = data['chatRoomId'];
//         print('Navigate to chat: $chatRoomId');
//         // TODO: navigationService.navigateToChat(chatRoomId);
//         break;

//       case 'workout_plan_update':
//         print('Navigate to workout plan');
//         // TODO: navigationService.navigateToWorkoutPlan();
//         break;

//       case 'check_in_reminder':
//         print('Navigate to check-in');
//         // TODO: navigationService.navigateToCheckIn();
//         break;
//     }
//   }
// }

// // ============================================
// // API SERVICE - Token Registration
// // ============================================

// class ApiService {
//   static const String baseUrl = 'YOUR_API_URL'; // TODO: Set your API URL

//   String? _authToken;
//   String? _refreshToken;

//   void setTokens(String authToken, String refreshToken) {
//     _authToken = authToken;
//     _refreshToken = refreshToken;
//   }

//   Future<bool> registerFCMToken(String fcmToken) async {
//     if (_authToken == null) return false;

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/mobile-app/notifications/register-token'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': _authToken!,
//           'x-refresh-token': _refreshToken ?? '',
//         },
//         body: jsonEncode({'fcmToken': fcmToken}),
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error registering FCM token: $e');
//       return false;
//     }
//   }

//   Future<bool> removeFCMToken() async {
//     if (_authToken == null) return false;

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/mobile-app/notifications/remove-token'),
//         headers: {
//           'Authorization': _authToken!,
//           'x-refresh-token': _refreshToken ?? '',
//         },
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error removing FCM token: $e');
//       return false;
//     }
//   }
// }

// // ============================================
// // USAGE IN main.dart
// // ============================================

// /*
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp();

//   // Initialize notifications
//   await NotificationService().initialize();

//   runApp(MyApp());
// }
// */

// // ============================================
// // USAGE IN LOGIN
// // ============================================

// /*
// class AuthService {
//   final ApiService _apiService = ApiService();
//   final NotificationService _notificationService = NotificationService();

//   Future<void> login(String email, String password) async {
//     // Your login logic...
//     final authToken = 'USER_AUTH_TOKEN';
//     final refreshToken = 'USER_REFRESH_TOKEN';

//     // Set tokens
//     _apiService.setTokens(authToken, refreshToken);

//     // Register FCM token
//     final fcmToken = _notificationService.fcmToken;
//     if (fcmToken != null) {
//       await _apiService.registerFCMToken(fcmToken);
//     }
//   }

//   Future<void> logout() async {
//     // Remove FCM token
//     await _apiService.removeFCMToken();

//     // Clear tokens
//     _apiService.setTokens('', '');

//     // Your logout logic...
//   }
// }
// */

// // ============================================
// // DEPENDENCIES (pubspec.yaml)
// // ============================================

// /*
// dependencies:
//   firebase_core: ^2.24.2
//   firebase_messaging: ^14.7.9
//   flutter_local_notifications: ^16.3.0
//   http: ^1.1.0
// */
