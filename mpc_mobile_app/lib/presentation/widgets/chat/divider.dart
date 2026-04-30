import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class DayDivider extends StatelessWidget {
  const DayDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "Today",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
      ],
    );
  }
}
