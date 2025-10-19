import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/UserExercise.dart';
import 'package:mpc_mobile_app/presentation/screens/training_plan.dart';
import 'package:mpc_mobile_app/presentation/widgets/column_builder.dart';

class ExercisesList extends StatelessWidget {
  ExercisesList({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    this.exercises = const [],
  });
  List<String> days;
  List<UserExercise> exercises;
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
        ColumnBuilder(
          itemBuilder: (context, i) {
            int minReps =
                exercises[i].sets != null && exercises[i].sets!.isNotEmpty
                    ? exercises[i].sets!
                        .map((e) => e.reps)
                        .reduce(
                          (value, element) => value < element ? value : element,
                        )
                    : 0;
            int maxReps =
                exercises[i].sets != null && exercises[i].sets!.isNotEmpty
                    ? exercises[i].sets!
                        .map((e) => e.reps)
                        .reduce(
                          (value, element) => value > element ? value : element,
                        )
                    : 0;
            return Container(
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
                          exercises[i].name ?? "Exercise Name",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                        Gap(4.h),
                        Row(
                          children: [
                            ExerciseInfoText(
                              value: "${exercises[i].sets!.length}",
                              label: "SETS",
                            ),

                            Divider(),
                            ExerciseInfoText(
                              value:
                                  minReps == maxReps
                                      ? "$minReps"
                                      : "$minReps-$maxReps",
                              label: "REPS",
                            ),
                            Divider(),
                            ExerciseInfoText(
                              value:
                                  "${exercises[i].minutes}:${exercises[i].seconds! < 10 ? '0${exercises[i].seconds}' : exercises[i].seconds}",
                              label: "REST",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: exercises.length,
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
