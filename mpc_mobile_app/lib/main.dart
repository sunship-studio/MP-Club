import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/core/theme/theme.dart';
import 'package:mpc_mobile_app/screens/active_workout.dart';
import 'package:mpc_mobile_app/screens/calorties.dart';
import 'package:mpc_mobile_app/screens/chat.dart';
import 'package:mpc_mobile_app/screens/check_in.dart';
import 'package:mpc_mobile_app/screens/check_in_info.dart';
import 'package:mpc_mobile_app/screens/forgot_password.dart';
import 'package:mpc_mobile_app/screens/home.dart';
import 'package:mpc_mobile_app/screens/login.dart';
import 'package:mpc_mobile_app/screens/new_password.dart';
import 'package:mpc_mobile_app/screens/submit_checkin.dart';
import 'package:mpc_mobile_app/screens/welcome.dart';
import 'package:mpc_mobile_app/screens/training_plan.dart';

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
        home: SubmitCheckIn(),
      ),
    );
  }
}
