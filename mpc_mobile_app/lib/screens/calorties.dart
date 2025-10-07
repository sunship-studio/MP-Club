import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/calories/add_calories.dart';
import 'package:mpc_mobile_app/widgets/calories/recent_log.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/header.dart';

class CaloriesScreen extends StatelessWidget {
  CaloriesScreen({super.key});

  List<Map<String, dynamic>> recentLogs = [
    {"title": "Breakfast", "calories": 500, "time": "8:00 AM"},
    {"title": "Lunch", "calories": 700, "time": "12:30 PM"},
    {"title": "Snack", "calories": 200, "time": "3:00 PM"},

    {"title": "Dinner", "calories": 600, "time": "7:00 PM"},

    {"title": "Dinner", "calories": 600, "time": "7:00 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MpcHeader(
            label: "CALORIES",
            backgroundColor: AppColors.darkScaffoldColor,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkCardColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Calories in",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/fire.svg",
                        width: 25.w,
                        height: 25.h,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "2000",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          letterSpacing: -1.2,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Text(
                                "kcal",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "Max 2,200 kcal",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: 2000 / 2200,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: AppColors.errorColor,
                    minHeight: 3.h,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddCalories(),
                    Gap(24.h),
                    RecentLog(recentLogs: recentLogs),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
