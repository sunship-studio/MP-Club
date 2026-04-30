import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/socket.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Handling background message: ${message.messageId}');
  debugPrint('Background notification data: ${message.data}');
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
  BuildContext? _navigationContext;

  /// Initialize Firebase and notification handlers
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      // Request permissions
      await _requestPermissions();

      // Configure local notifications
      await _configureLocalNotifications();

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('✅ FCM Token: $_fcmToken');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // Register new token with backend
        _registerTokenWithBackend(newToken);
      });

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps (background/terminated state)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App opened from notification: ${initialMessage.data}');
        // Delay navigation until app is ready
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(initialMessage);
        });
      }

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Set navigation context for routing
  void setNavigationContext(BuildContext context) {
    _navigationContext = context;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  /// Configure local notifications for foreground display
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
        // Handle notification tap from local notification
        if (details.payload != null) {
          _handleLocalNotificationTap(details.payload!);
        }
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification?.title}',
      );

      // Show local notification
      await _showLocalNotification(message);

      // Refresh chat if socket is connected
      final socketService = getIt<SocketService>();
      if (socketService.isConnected && message.data['type'] == 'chat_message') {
        // Socket will handle the message via the messageStream
        debugPrint('💬 Chat message received, socket will update UI');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_messages',
            'Chat Messages',
            channelDescription: 'Notifications for new chat messages',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap (background/terminated state)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.data}');

    final type = message.data['type'];

    switch (type) {
      case 'chat_message':
        final clientId = message.data['chatRoomId'] ?? message.data['clientId'];
        debugPrint('📱 Navigating to chat with clientId: $clientId');
        _navigateToChat(clientId);
        break;

      case 'workout_plan_update':
        debugPrint('💪 Navigating to workout plan');
        _navigateTo('/training');
        break;

      case 'check_in_reminder':
        debugPrint('📝 Navigating to check-in');
        _navigateTo('/check_in/submit');
        break;

      default:
        debugPrint('⚠️ Unknown notification type: $type');
        break;
    }
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      debugPrint('👆 Local notification tapped: $data');

      // Use the same handling logic as remote notifications
      final type = data['type'];

      switch (type) {
        case 'chat_message':
          final clientId = data['chatRoomId'] ?? data['clientId'];
          _navigateToChat(clientId);
          break;

        case 'workout_plan_update':
          _navigateTo('/training');
          break;

        case 'check_in_reminder':
          _navigateTo('/check_in/submit');
          break;

        default:
          debugPrint('⚠️ Unknown notification type: $type');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
    }
  }

  /// Navigate to chat screen
  void _navigateToChat(String? clientId) {
    if (clientId == null) {
      debugPrint('⚠️ Cannot navigate to chat: clientId is null');
      return;
    }

    if (_navigationContext != null && _navigationContext!.mounted) {
      // Use go_router to navigate
      _navigationContext!.push('/home/chat');
    } else {
      // Fallback: use global navigator key if available
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.push('/home/chat');
      } else {
        debugPrint('⚠️ No navigation context available');
      }
    }
  }

  /// Navigate to a specific route
  void _navigateTo(String route) {
    if (_navigationContext != null && _navigationContext!.mounted) {
      _navigationContext!.push(route);
    } else {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.push(route);
      } else {
        debugPrint('⚠️ No navigation context available');
      }
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final dioClient = getIt<DioClient>();
      final response = await dioClient.registerFCMToken(token);

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token registered with backend successfully');
      } else {
        debugPrint('⚠️ Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error registering token with backend: $e');
    }
  }

  /// Public method to register token (called after login)
  Future<bool> registerToken(String token) async {
    try {
      await _registerTokenWithBackend(token);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to register FCM token: $e');
      return false;
    }
  }

  /// Remove FCM token from backend (called on logout)
  Future<bool> removeToken() async {
    try {
      final dioClient = getIt<DioClient>();
      final response = await dioClient.removeFCMToken();

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token removed from backend successfully');
        return true;
      } else {
        debugPrint('⚠️ Failed to remove FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
      return false;
    }
  }

  /// Subscribe to topic (optional, for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Dispose (called on logout or app termination)
  void dispose() {
    _navigationContext = null;
    debugPrint('🧹 NotificationService disposed');
  }
}
