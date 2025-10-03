import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/core/theme/theme.dart';
import 'package:mpc_mobile_app/screens/forgot_password.dart';
import 'package:mpc_mobile_app/screens/home.dart';
import 'package:mpc_mobile_app/screens/login.dart';
import 'package:mpc_mobile_app/screens/new_password.dart';
import 'package:mpc_mobile_app/screens/welcome.dart';

void main(List<String> args) {
  runApp(const MpcApp());
}

class MpcApp extends StatelessWidget {
  const MpcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,

      child: MaterialApp(
        
        title: 'MP Club',
        theme: AppTheme.appTheme,
        home: HomeScreen(),
      ),
    );
  }
}
