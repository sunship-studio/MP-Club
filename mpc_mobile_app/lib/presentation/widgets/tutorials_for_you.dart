import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';
import 'package:mpc_mobile_app/presentation/widgets/tutorial_box.dart';

class TutorialsForYou extends StatelessWidget {
  TutorialsForYou({super.key, required this.forYou});
  List<Exercise> forYou;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Text(
                "Tutorials for you",
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
                "See More",

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
        ),
        Gap(10.h),
        SizedBox(
          height: 180.h,
          child: ListView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            scrollDirection: Axis.horizontal,
            children: [
              TutorialBox(exercise: forYou[0]),
              Gap(10.w),
              TutorialBox(exercise: forYou[1]),
              Gap(10.w),
              TutorialBox(exercise: forYou[2]),
            ],
          ),
        ),
      ],
    );
  }
}
