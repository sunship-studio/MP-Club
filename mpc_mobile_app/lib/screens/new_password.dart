import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/main.dart';
import 'package:mpc_mobile_app/screens/login.dart';
import 'package:mpc_mobile_app/widgets/back_button.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/onboarding_input.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: Container(
        margin: EdgeInsets.only(
          top: topPadding(context) - horizontalPadding.w,
          bottom: bottomPadding(context),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MpcBackButton(),

            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NEW PASSWORD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),

                  SizedBox(height: 8),
                  Text(
                    "Enter your new password below to regain access to your account.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  OnboardingInput(
                    label: "Password",
                    hintText: "Input Password",
                    password: true,
                  ),
                  SizedBox(height: verticalPadding),
                  OnboardingInput(
                    label: "Repeat New Password",
                    hintText: "Input Password",
                    password: true,
                  ),
                  SizedBox(height: verticalPadding),
                  CircularButton(label: "Update Password", dark: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
