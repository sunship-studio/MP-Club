import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_admin_app/app/services/notification_service.dart';
import 'package:mpc_admin_app/core/router/app_router.dart';

bool debug = false;
String admin_key = 'shanempc113@';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  if (debug) {
    debugPrint("Debug mode is enabled");
  } else {
    debugPrint("Debug mode is disabled");
  }

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService().initialize();

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
