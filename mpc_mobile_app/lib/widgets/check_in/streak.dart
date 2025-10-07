import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class CheckInStreak extends StatelessWidget {
  const CheckInStreak({super.key});

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
                      "3",
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