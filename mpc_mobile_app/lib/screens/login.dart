import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/onboarding/onboarding_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: Container(
        margin: EdgeInsets.only(bottom: bottomPadding(context)),

        child: Column(
          children: [
            IntrinsicHeight(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: topPadding(context)),
                    color: Colors.black,
                    child: Image.asset('assets/images/login_header.png'),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Image.asset('assets/images/logo.png', width: 140),
                      margin: EdgeInsets.only(bottom: 16.h),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.w),

              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      children: [
                        Text(
                          "WELCOME TO MPC",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            letterSpacing: -0.9,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 6),
                        Text(
                          "Let's become more stronger today",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  OnboardingInput(
                    label: "Email Address",
                    hintText: "Email address...",
                  ),
                  SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 900),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child:
                        _showPassword
                            ? Container(
                              margin: EdgeInsets.only(bottom: 24.h),
                              key: ValueKey('password'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  OnboardingInput(
                                    label: "Password",
                                    hintText: "Input Password",
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 1),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  CircularButton(
                    label: "Sign In",
                    dark: false,
                    onTap: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        _showPassword = true;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Purchase a Membership",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 1),
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Text(
              "Accounts are created via membership purchase on the",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
              ),
            ),
            Text(
              "Private Website",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 1),
                fontSize: 12.sp,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

