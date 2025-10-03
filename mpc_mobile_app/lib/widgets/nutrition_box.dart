import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class NutritionBox extends StatelessWidget {
  NutritionBox({
    super.key,
    this.title = "Carbs",
    this.progress = 0.7,
    this.current = 200,
    this.total = 300,
    this.progressColor = AppColors.redColor,
  });
  Color progressColor;
  String title;
  double progress;
  int current;
  int total;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.darkTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: AppColors.greyTextColor.withValues(alpha: 0.2),
                color: progressColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      color: AppColors.darkTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    '/ $total g',
                    style: TextStyle(
                      color: AppColors.greyTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
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
