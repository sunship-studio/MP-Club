import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/calories.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';

class AddCalories extends StatelessWidget {
  AddCalories({super.key, required this.userId});
  String userId;
  TextEditingController caloriesController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Add Calories",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextColor,
              ),
            ),
          ],
        ),

        TextField(
          controller: caloriesController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 58.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: "0",
            hintStyle: TextStyle(
              fontSize: 58.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor.withValues(alpha: 0.3),
            ),
            border: InputBorder.none,
          ),
        ),
        Container(
          width: double.infinity,
          height: 2.h,
          color: AppColors.darkTextColor.withValues(alpha: 0.7),
        ),
        SizedBox(height: 16.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Note / Meal Description (Optional)",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextColor.withValues(alpha: 0.8),
              ),
            ),
            Gap(4.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  width: 1,
                  color: AppColors.greyTextColor.withValues(alpha: 0.4),
                ),
              ),
              child: TextField(
                maxLines: 3,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkTextColor,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.w),
                  hintText: "Placeholder",
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyTextColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        Gap(16.h),
        CircularButton(
          color: AppColors.darkButtonColor,
          label: "Submit",
          dark: true,
          onTap: () async {
            context.read<CaloriesCubit>().logCalories(
              caloriesController.text,
              noteController.text,
              userId,
            );
          },
        ),
      ],
    );
  }
}
