import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/main.dart';
import 'package:mpc_mobile_app/presentation/screens/login.dart';
import 'package:mpc_mobile_app/presentation/widgets/back_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/onboarding/onboarding_input.dart';

class SetPasswordScreen extends StatelessWidget {
  SetPasswordScreen({super.key, required this.email});
  String email;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _repeatPasswordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SET PASSWORD",
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
                      "Create your new password below to get access to your new account.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: verticalPadding),
                    OnboardingInput(
                      validator: Constants.passwordValidator,
                      controller: _passwordController,
                      label: "Password",
                      hintText: "Input Password",
                      password: true,
                    ),
                    SizedBox(height: verticalPadding),
                    OnboardingInput(
                      controller: _repeatPasswordController,
                      validator:
                          (value) => Constants.repeatPasswordValidator(
                            value,
                            _passwordController.text,
                          ),
                      label: "Repeat New Password",
                      hintText: "Input Password",
                      password: true,
                    ),
                    SizedBox(height: verticalPadding),
                    CircularButton(
                      label: "Set Password",
                      dark: false,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          // Proceed to set password
                          await context.read<AuthCubit>().setPassword(
                            email,
                            _passwordController.text,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
