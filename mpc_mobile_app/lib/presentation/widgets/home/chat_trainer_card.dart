import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/main.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/socket.dart';

class ChatTrainerCard extends StatefulWidget {
  const ChatTrainerCard({super.key});

  @override
  State<ChatTrainerCard> createState() => _ChatTrainerCardState();
}

class _ChatTrainerCardState extends State<ChatTrainerCard> {
  final SocketService _socketService = getIt<SocketService>();
  void _connectTo() async {
    final token = await getIt<TokenStorage>().getAccessToken() ?? '';
    final refreshToken = await getIt<TokenStorage>().getRefreshToken() ?? '';
    await _socketService.connect(
      debugMode
          ? 'ws://localhost:3500'
          : 'wss://mp-club-production.up.railway.app',
      token,
      refreshToken,
    );
  }

  @override
  void initState() {
    _connectTo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _socketService.unreadCountStream,
      builder: (context, snapshot) {
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
                    snapshot.hasData && snapshot.data! > 0
                        ? "${snapshot.data} unread messages"
                        : "No unread messages",
                    style: TextStyle(
                      color:
                          snapshot.hasData && snapshot.data! > 0
                              ? AppColors.redColor.withValues(alpha: 0.8)
                              : AppColors.lightTextColor.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                      fontWeight:
                          snapshot.hasData && snapshot.data! > 0
                              ? FontWeight.w600
                              : FontWeight.w500,
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
      },
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
            navBarKey.currentState?.turnOffNavBar();
            getIt<MainRouter>().router.push('/home/chat');
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
