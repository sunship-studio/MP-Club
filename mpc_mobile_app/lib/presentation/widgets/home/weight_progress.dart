import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class WeightProgress extends StatelessWidget {
  WeightProgress({super.key, required this.user});
  User user;
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
                    user.checkIns.isNotEmpty
                        ? user.checkIns.last.weight.toStringAsFixed(0)
                        : '--',
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
                    "kg",
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
              if (user.targetWeight != null)
                LinearProgressIndicator(
                  value:
                      user.checkIns.isNotEmpty
                          ? (user.checkIns.last.weight - user.targetWeight!) /
                              (user.checkIns.first.weight - user.targetWeight!)
                          : 0,
                  backgroundColor: Colors.black38,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.blueColor,
                  ),
                ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Weight",
                    style: TextStyle(
                      color: AppColors.lightTextColor.withValues(alpha: 1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: -0.6,
                    ),
                  ),
                  if (user.targetWeight != null) ...[
                    Gap(4),
                    Text(
                      "Target ${user.targetWeight} kg",
                      style: TextStyle(
                        color: AppColors.greyTextColor.withValues(alpha: 0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
