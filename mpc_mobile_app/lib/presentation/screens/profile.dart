import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/profile.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/sheets/browse_file.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfilePictureUpdated) {
            context.read<AuthCubit>().loadUser();
            SnackBarService.show(
              context: context,
              message: "Profile picture updated successfully!",
              isError: false,
              isNavBar: true,
            );
          } else if (state is ProfilePictureUpdateFailed) {
            SnackBarService.show(
              context: context,
              message: "Failed to update profile picture.",
              isError: true,
              isNavBar: true,
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            authState as Authenticated;
            return Column(
              children: [
                MpcHeader(
                  suffix: Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                    size: 24.w,
                  ),
                  onSuffixTap: () => {context.read<AuthCubit>().logout()},
                  label: 'Profile',
                  back: true,
                  backgroundColor: AppColors.darkScaffoldColor,
                ),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkScaffoldColor,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (state is ProfileLoading) ...[
                                Container(
                                  width: 70.w,
                                  height: 70.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ] else ...[
                                ProfileAvatar(
                                  radius: 35.w,
                                  user: authState.user,
                                  onTap: () {
                                    navBarKey.currentState?.turnOffNavBar();
                                    showBrowseFileSheet(
                                      context,
                                      title: 'CHANGE PROFILE PICTURE',
                                      showNavBarAfter: true,
                                    ).then((file) {
                                      if (file != null) {
                                        context
                                            .read<ProfileCubit>()
                                            .updateProfilePicture(
                                              file,
                                              authState.user.id,
                                            );
                                      }
                                    });
                                  },
                                ),
                              ],
                              Gap(12.w),
                              SizedBox(
                                height: 80.w,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${authState.user.firstName} ${authState.user.lastName}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "🛜 Online Coaching",
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 1,
                                              ),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "Expires Dec 2025",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        // color: AppColors.lightScaffoldColor
                                        //     .withValues(alpha: 0.5),
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(child: CloseAccountButton()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CloseAccountButton extends StatefulWidget {
  const CloseAccountButton({super.key});

  @override
  State<CloseAccountButton> createState() => _CloseAccountButtonState();
}

class _CloseAccountButtonState extends State<CloseAccountButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {},

      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.99 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 16.h,
            horizontal: horizontalPadding.w,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: 20.w,
                      color: AppColors.textSubColor,
                    ),
                    Gap(12.w),
                    Text(
                      "Close account",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.darkTextColor,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Coolicons.chevron_right,
                      color: AppColors.textSubColor,
                      size: 16.w,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
