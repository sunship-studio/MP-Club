import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_admin_app/core/router/app_router.dart';

bool debug = false;
String admin_key = 'shanempc113@';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (debug) {
    // Enable debug mode
    debugPrint("Debug mode is enabled");
  } else {
    // Disable debug mode
    debugPrint("Debug mode is disabled");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true);

  // Only proceed if user granted permission
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get the token
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');

      // For iOS, specifically get the APNS token
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print('APNS Token: $apnsToken');
    } catch (e) {
      debugPrint("cant get aspn");
    }
  }

  runApp(const MpcApp());
}

class MpcApp extends StatelessWidget {
  const MpcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: 'MPC Admin App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(20, 163, 230, 1),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
