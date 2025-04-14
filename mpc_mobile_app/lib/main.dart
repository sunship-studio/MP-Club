import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:mpc_mobile_app/core/screens/HomeScreen.dart';
import 'package:mpc_mobile_app/core/screens/OnlineCoaching.dart';
import 'package:mpc_mobile_app/core/screens/WaitingList.dart';

bool debug = true;
String admin_key = 'shanempc113@';
void main() {
  if (debug) {
    // Enable debug mode
    debugPrint("Debug mode is enabled");
  } else {
    // Disable debug mode
    debugPrint("Debug mode is disabled");
  }
  runApp(MpcApp());
}

class MpcApp extends StatefulWidget {
  const MpcApp({super.key});

  @override
  State<MpcApp> createState() => _MpcAppState();
}

class _MpcAppState extends State<MpcApp> {
  void changeScreen(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      HomeScreen(changeScreen: changeScreen),
      Waitinglist(),
      OnlineCoaching(),
    ];
    return MaterialApp(
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
              Container(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
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
                                    setState(() {
                                      currentIndex = 0;
                                    });
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Image.asset('assets/logo.png'),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: routes[currentIndex]),
            ],
          ),
        ),
      ),
    );
  }
}
