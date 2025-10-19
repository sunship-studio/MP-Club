import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';

class ChatTrainerCard extends StatelessWidget {
  const ChatTrainerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        children: [
          ProfileAvatar(radius: 18.h),
          Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Coach Shane",
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                "Active 2h ago",
                style: TextStyle(
                  color: AppColors.lightTextColor.withValues(alpha: 0.6),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Button(),
        ],
      ),
    );
  }
}

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        state as AuthAuthenticated;
        return GestureDetector(
          onTap: () {
            navBarKey.currentState?.toggleNavBar();
            getIt<MainRouter>().router.push('/home/chat', extra: state.user);
          },
          onTapDown: (details) => setState(() => _isPressed = true),
          onTapUp: (details) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkButtonColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.grey[200]!.withValues(alpha: 0.04),
                  width: 1.5,
                  strokeAlign: -1,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
              child: Text(
                "Chat Trainer",
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 14.sp,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
