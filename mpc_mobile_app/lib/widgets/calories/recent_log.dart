import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class RecentLog extends StatelessWidget {
  const RecentLog({super.key, required this.recentLogs});

  final List<Map<String, dynamic>> recentLogs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Recent Log",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (var log in recentLogs)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/images/fire.svg", width: 16.w),
                    Text(
                      " ${log['calories']} Kcal",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    Gap(16.w),
                    Spacer(),
                    Text(
                      log['time'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
