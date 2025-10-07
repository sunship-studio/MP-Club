import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/check_in/calendar.dart';
import 'package:mpc_mobile_app/widgets/check_in/details.dart';
import 'package:mpc_mobile_app/widgets/check_in/my_checkpoints.dart';
import 'package:mpc_mobile_app/widgets/check_in/streak.dart';
import 'package:mpc_mobile_app/widgets/check_in/workouts.dart';
import 'package:mpc_mobile_app/widgets/header.dart';
import 'package:mpc_mobile_app/widgets/home/check_in_card.dart';

class CheckInScreen extends StatelessWidget {
  CheckInScreen({super.key});

  GlobalKey<CalendarState> calendarKey = GlobalKey<CalendarState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,

      body: Column(
        children: [
          Column(
            children: [
              MpcHeader(
                suffix: Icon(
                  Coolicons.info_circle_outline,
                  color: Colors.white,
                  size: 24.w,
                ),
                onSuffixTap: () => print("Info tapped"),
                label: "CHECK-IN",
                backgroundColor: AppColors.darkScaffoldColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding.w,
                  vertical: 16.h,
                ),
                decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
                child: Column(
                  children: [
                    MonthSwitch(),

                    Calendar(key: calendarKey),

                    Row(
                      children: [
                        CheckInStreak(),
                        Gap(10.w),
                        WorkoutsThisWeek(),
                      ],
                    ),
                    Gap(16.h),
                    CheckInButton(),
                  ],
                ),
              ),
            ],
          ),
          Checkpoints(calendarKey: calendarKey),
        ],
      ),
    );
  }
}

class MonthSwitch extends StatelessWidget {
  const MonthSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "October 2025",
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "Friday, 3 Oct",
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
        Spacer(),
        Container(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            Coolicons.chevron_big_left,
            size: 16,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!.withValues(alpha: 0.1)),
            shape: BoxShape.circle,
            color: AppColors.darkButtonColor,
          ),
        ),
        Gap(5.w),
        Container(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            Coolicons.chevron_big_right,
            size: 16,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!.withValues(alpha: 0.1)),
            shape: BoxShape.circle,
            color: AppColors.darkButtonColor,
          ),
        ),
      ],
    );
  }
}
