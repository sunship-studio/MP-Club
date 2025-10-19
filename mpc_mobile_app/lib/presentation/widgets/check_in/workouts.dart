import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class WorkoutsAmount extends StatelessWidget {
  WorkoutsAmount({
    super.key,
    required this.user,
    this.selectedMonth,
    this.selectedYear,
  });
  User user;
  int? selectedMonth;
  int? selectedYear;

  int getWorkoutsAmount() {
    int count = 0;
    for (var workout in user.doneWorkouts) {
      if (selectedMonth != null && selectedYear != null) {
        if (workout.date.month == selectedMonth &&
            workout.date.year == selectedYear) {
          count++;
        }
      } else {
        // From last 7 days
        DateTime now = DateTime.now();
        DateTime sevenDaysAgo = now.subtract(Duration(days: 7));
        if (workout.date.isAfter(sevenDaysAgo) &&
            workout.date.isBefore(now.add(Duration(days: 1)))) {
          count++;
        }
      }
    }
    return count;
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
              "Total Workouts",
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
                  "assets/images/dumbbell.svg",
                  width: 24.w,
                  height: 24.w,
                ),
                Gap(6.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getWorkoutsAmount().toString(),
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
                        "workouts",
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
