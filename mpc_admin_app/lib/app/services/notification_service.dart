import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mpc_admin_app/app/network/api.dart';
import 'package:mpc_admin_app/core/router/app_router.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📬 Background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;

  /// Initialize notifications - Call this in main()
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      // Request permissions
      await _requestPermissions();

      // Configure local notifications
      await _configureLocalNotifications();

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      ApiService().saveFCMToken(_fcmToken ?? '');
      // Get APNS token for iOS
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('🍎 APNS Token: $apnsToken');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;

        ApiService().saveFCMToken(newToken);
      });

      // Set up message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check initial message (app opened from terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App opened from notification');
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('📋 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional notification permissions');
    } else {
      debugPrint(
        '❌ User declined or has not accepted notification permissions',
      );
    }
  }

  Future<void> _configureLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Local notification tapped: ${details.payload}');
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            _navigateFromNotification(data);
          } catch (e) {
            debugPrint('Error parsing notification payload: $e');
          }
        }
      },
    );

    // Create Android notification channels
    await _createAndroidChannels();
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin == null) return;

    // Chat messages channel
    const chatChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Workout updates channel
    const workoutChannel = AndroidNotificationChannel(
      'workout_updates',
      'Workout Updates',
      description: 'Notifications for workout plan updates',
      importance: Importance.high,
      playSound: true,
    );

    // Check-in reminders channel
    const checkInChannel = AndroidNotificationChannel(
      'check_in_reminders',
      'Check-in Reminders',
      description: 'Reminders to complete your check-ins',
      importance: Importance.high,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(chatChannel);
    await androidPlugin.createNotificationChannel(workoutChannel);
    await androidPlugin.createNotificationChannel(checkInChannel);

    debugPrint('✅ Android notification channels created');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Determine channel based on notification type
    final type = message.data['type'] as String?;
    String channelId = 'chat_messages';

    switch (type) {
      case 'workout_plan_update':
        channelId = 'workout_updates';
        break;
      case 'check_in_reminder':
        channelId = 'check_in_reminders';
        break;
      default:
        channelId = 'chat_messages';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: Importance.high,
      priority: Priority.high,
      ticker: notification.title,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'chat_messages':
        return 'Chat Messages';
      case 'workout_updates':
        return 'Workout Updates';
      case 'check_in_reminders':
        return 'Check-in Reminders';
      default:
        return 'Notifications';
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('🔔 Notification tapped');
    debugPrint('Data: ${message.data}');

    _navigateFromNotification(message.data);
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    if (type == null) {
      debugPrint('⚠️ Notification type is null, cannot navigate');
      return;
    }

    debugPrint('🧭 Navigating to: $type');

    // Add a small delay to ensure the app is fully loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      switch (type) {
        case 'chat_message':
          final userId = data['userId'] as String?;
          final chatRoomId = data['chatRoomId'] as String?;

          debugPrint('💬 Navigate to chat - User: $userId, Room: $chatRoomId');

          // Navigate to chat screen
          // Note: You'll need to fetch the User object if needed
          if (userId != null || chatRoomId != null) {
            appRouter.push('/onlineCoaching');
          } else {
            appRouter.push('/onlineCoaching');
          }
          break;

        case 'waiting-list':
          debugPrint('💪 Navigate to waiting list');
          appRouter.push('/waitingList');
          break;

        case 'check_in':
          debugPrint('📝 Navigate to check-in');
          appRouter.push('/onlineCoaching');
          break;

        default:
          debugPrint('⚠️ Unknown notification type: $type');
          // Navigate to home as fallback
          appRouter.go('/');
      }
    });
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('🧹 All notifications cleared');
  }

  /// Clear notification by ID
  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
    debugPrint('🧹 Notification $id cleared');
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
