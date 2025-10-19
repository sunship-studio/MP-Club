import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class CaloriesProgress extends StatelessWidget {
  CaloriesProgress({super.key, required this.user});
  User user;

  int getUserTodayCalories(User user) {
    DateTime today = DateTime.now();
    int total = 0;
    for (var log in user.caloriesLogs) {
      if (log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day) {
        total += log.calories;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    getUserTodayCalories(user).toString(),
                    style: TextStyle(
                      color: AppColors.lightTextColor,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: -1.8,
                      height: 1,
                    ),
                  ),
                  Gap(4),
                  Text(
                    "kcal",
                    style: TextStyle(
                      color: AppColors.greyTextColor.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),

              LinearProgressIndicator(
                value: getUserTodayCalories(user) / user.caloriesPerDay!,
                backgroundColor: Colors.black38,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.redColor),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Intake",
                    style: TextStyle(
                      color: AppColors.lightTextColor.withValues(alpha: 1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: -0.6,
                    ),
                  ),
                  Gap(4),
                  Text(
                    "Max ${user.caloriesPerDay} kcal",
                    style: TextStyle(
                      color: AppColors.greyTextColor.withValues(alpha: 0.6),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
