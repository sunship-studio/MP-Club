import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/screens/training_plan.dart';

class ExercisesList extends StatelessWidget {
  ExercisesList({
    super.key,
    required this.days,
    required this.selectedDayIndex,
  });
  List<String> days;
  int selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${days[selectedDayIndex]}",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        Gap(12.h),
        for (var i = 0; i < 3; i++)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.asset("assets/images/exercise.svg"),
                  decoration: BoxDecoration(
                    color: AppColors.lightScaffoldColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Bench Press",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                      Gap(4.h),
                      Row(
                        children: [
                          ExerciseInfoText(value: "15", label: "KG"),
                          Divider(),
                          ExerciseInfoText(value: "4", label: "SETS"),
                          Divider(),
                          ExerciseInfoText(value: "10", label: "REPS"),
                          Divider(),
                          ExerciseInfoText(value: "120s", label: "REST"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: AppColors.darkTextColor.withValues(alpha: 0.3),
    );
  }
}

class ExerciseInfoText extends StatelessWidget {
  ExerciseInfoText({super.key, this.value = "15", this.label = "KG"});

  String value;
  String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor.withValues(alpha: 0.9),
          ),
        ),
        Gap(3.w),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor.withValues(alpha: 0.6),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

