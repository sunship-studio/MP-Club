import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/presentation/widgets/training_plan/exercises.dart';

class FocusedBodyParts extends StatelessWidget {
  FocusedBodyParts({super.key, required this.bodyParts});

  List<String> bodyParts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BODY FOCUS",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
            letterSpacing: -0.4,
          ),
        ),
        Gap(8.h),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: LayoutGrid(
            columnSizes: [1.fr, 1.fr], // 2 equal columns
            rowSizes: repeat((bodyParts.length / 2).ceil(), [
              auto,
            ]), // 3 rows with auto height
            rowGap: 8.h,

            children: [for (var part in bodyParts) BodyPart(label: part)],
          ),
        ),
      ],
    );
  }
}

class BodyPart extends StatelessWidget {
  BodyPart({super.key, this.label = "Back"});
  String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.darkTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 11.sp,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
