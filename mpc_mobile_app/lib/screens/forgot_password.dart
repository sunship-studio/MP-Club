import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/screens/login.dart';
import 'package:mpc_mobile_app/widgets/back_button.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/onboarding_input.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
             SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FORGOT PASSWORD",
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
                    "Enter your email to reset your password.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  OnboardingInput(
                    label: "Email address",
                    hintText: "Email address...",
                  ),
                  SizedBox(height: verticalPadding),
                  CircularButton(label: "Send Reset Link", dark: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

