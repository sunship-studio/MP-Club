import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/routes/main.dart';

class ChatScreenHeader extends StatelessWidget {
  const ChatScreenHeader({
    super.key,
    required this.buildConnectionIndicator,
    required this.isOnline,
    required this.lastSeenText,
  });

  final Widget Function() buildConnectionIndicator;
  final bool isOnline;
  final String lastSeenText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: EdgeInsets.only(
                right: horizontalPadding.w - 10.w,
                left: horizontalPadding.w,
                top: topPadding(context),
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
            padding: EdgeInsets.only(top: topPadding(context), bottom: 16.h),
            child: Row(
              children: [
                Stack(
                  children: [
                    ProfileAvatar(radius: 20.w),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.w),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shane Mahon",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    Text(
                      lastSeenText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: isOnline ? Colors.green : Colors.grey,
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
