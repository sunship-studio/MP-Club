import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/presentation/widgets/back_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/onboarding/onboarding_input.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key, required this.email});
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            SnackBarService.show(
              context: context,

              message:
                  "A password reset link has been sent to your email address.",
            );
            context.pop();
          } else if (state is ForgotPasswordError) {
            SnackBarService.show(context: context, message: state.message);
          }
        },

        child: Container(
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
                      enabled: false,

                      controller: TextEditingController(text: email),
                      label: "Email address",
                      hintText: "Email address...",
                    ),
                    SizedBox(height: verticalPadding),
                    CircularButton(
                      label: "Send Reset Link",
                      dark: false,
                      isLoading:
                          context.watch<AuthCubit>().state
                              is ForgotPasswordLoading,
                      onTap: () async {
                        context.read<AuthCubit>().forgotPassword(email);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
