import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/widgets/profile_avatar.dart';

class ChatScreenHeader extends StatelessWidget {
  ChatScreenHeader({
    super.key,
    required this.buildConnectionIndicator,
    required this.isOnline,
    required this.lastSeenText,
    required this.changeScreen,
    required this.user,
  });
  Function changeScreen;
  final Widget Function() buildConnectionIndicator;
  final bool isOnline;
  final User user;
  final String lastSeenText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              changeScreen(2);
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: EdgeInsets.only(
                right: 25.w - 10.w,
                left: 25.w,
                top: MediaQuery.of(context).padding.top + 16.h,
                bottom: 16.h,
              ),
              child: Icon(
                Coolicons.chevron_big_left,
                size: 20.w,
                color: AppColors.darkTextColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 16.h,
            ),
            child: Row(
              children: [
                Stack(children: [ProfileAvatar(radius: 20.w)]),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          buildConnectionIndicator(),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
}
