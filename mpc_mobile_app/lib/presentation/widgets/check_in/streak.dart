import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class CheckInStreak extends StatelessWidget {
  CheckInStreak({super.key, required this.user});
  User user;
  int getNumberOfDaysStreak() {
    int streak = 0;
    if (user.checkIns.last.date.day == DateTime.now().day &&
        user.checkIns.last.date.month == DateTime.now().month &&
        user.checkIns.last.date.year == DateTime.now().year) {
      streak = 1;
    } else {
      return 0;
    }

    final checkIns = user.checkIns;
    for (int i = checkIns.length - 1; i > 0; i--) {
      DateTime currentDate = checkIns[i].date;
      DateTime previousDate = checkIns[i - 1].date;
      Duration difference = currentDate.difference(previousDate);
      print(difference.inDays);
      if (difference.inDays == 1 ||
          difference.inDays == 0 && currentDate.day != previousDate.day) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Day Streak",
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.4,
              ),
            ),

            Gap(10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/fire.svg",
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.redColor,
                    BlendMode.srcIn,
                  ),
                ),
                Gap(4.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getNumberOfDaysStreak().toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        letterSpacing: -0.4,
                      ),
                    ),
                    Gap(4.w),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.h),
                      child: Text(
                        "days",
                        style: TextStyle(
                          color: AppColors.greyTextColor.withValues(alpha: 0.6),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
