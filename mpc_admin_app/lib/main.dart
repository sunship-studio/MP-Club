import 'package:coolicons/coolicons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/services/socket.dart';
import 'package:mpc_admin_app/core/screens/chat.dart';
import 'package:mpc_admin_app/core/screens/home.dart';
import 'package:mpc_admin_app/core/screens/online_coaching.dart';
import 'package:mpc_admin_app/core/screens/waiting_list.dart';

bool debug = true;
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

  runApp(MpcApp());
}

class MpcApp extends StatefulWidget {
  const MpcApp({super.key});

  @override
  State<MpcApp> createState() => _MpcAppState();
}

class _MpcAppState extends State<MpcApp> {
  void changeScreen(int index, {User? user}) {
    if (index == 2) {
      SocketService().connect(
        debug
            ? 'http://localhost:3500'
            : "wss://mp-club-production.up.railway.app",
        admin_key,
      );
    }
    setState(() {
      currentIndex = index;
      this.user = user;
    });
  }

  bool planEditor = false;
  User? user;
  void togglePlanEditor(User user) {
    setState(() {
      this.user = user;
      planEditor = !planEditor;
    });
  }

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      HomeScreen(changeScreen: changeScreen),
      WaitingList(),
      OnlineCoaching(
        changeScreen: changeScreen,
        togglePlanEditor: togglePlanEditor,
        planEditor: planEditor,
        user: user,
      ),
      ChatScreen(user: user, isAdmin: true, changeScreen: changeScreen),
    ];
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(20, 163, 230, 1),
          ),
        ),
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color.fromARGB(255, 17, 138, 194), Colors.black],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentIndex != 3
                    ? Container(
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 10,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              currentIndex != 0
                                  ? Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        onPressed: () {
                                          if (planEditor) {
                                            togglePlanEditor(user!);
                                          } else {
                                            setState(() {
                                              currentIndex = 0;
                                            });
                                          }
                                        },
                                        icon: Icon(
                                          Coolicons.chevron_big_left,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Expanded(child: Container()),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Image.asset('assets/logo.png'),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (planEditor) {
                                      // Save action
                                      // Implement your save logic here
                                      togglePlanEditor(user!);
                                    }
                                  },
                                  child: Container(
                                    child: planEditor ? Save() : Container(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    : Container(),
                Expanded(child: routes[currentIndex]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Save extends StatelessWidget {
  const Save({super.key});

  @override
  Widget build(BuildContext context) {
    // return Align(
    //   alignment: Alignment.centerRight,
    //   child: Container(
    //     padding: EdgeInsets.symmetric(
    //       horizontal: 10,
    //       vertical: 5,
    //     ),
    //     decoration: BoxDecoration(
    //       color: Color.fromRGBO(
    //         22,
    //         133,
    //         184,
    //         1,
    //       ),
    //       borderRadius: BorderRadius.circular(
    //         8,
    //       ),
    //     ),
    //     child: Text(
    //       "Save",
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontFamily: 'SF-Pro',
    //         fontSize: 16,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //   ),
    // );
    return Container();
  }
}
