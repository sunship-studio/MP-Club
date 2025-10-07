import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/home/nutrition_box.dart';

class FoodGuidelines extends StatelessWidget {
  FoodGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Food Guidelines",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
                color: AppColors.darkTextColor,
              ),
            ),
            Spacer(),
            Text(
              "More Details",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: AppColors.greyTextColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Gap(10.h),
        Row(
          children: [
            NutritionBox(),
            Gap(10),
            NutritionBox(
              title: "Protein",
              progress: 0.5,
              current: 150,
              total: 300,
              progressColor: AppColors.blueColor,
            ),
            Gap(10),
            NutritionBox(
              title: "Fats",
              progress: 0.3,
              current: 80,
              total: 300,
              progressColor: AppColors.orangeColor,
            ),
          ],
        ),
      ],
    );
  }
}
