import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/header.dart';
import 'package:mpc_mobile_app/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/widgets/training_plan/days_selector.dart';
import 'package:mpc_mobile_app/widgets/training_plan/exercises.dart';
import 'package:mpc_mobile_app/widgets/training_plan/focused_body_parts.dart';

class TrainingPlanScreen extends StatefulWidget {
  TrainingPlanScreen({super.key});

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  int selectedDayIndex = 0;
  List<String> days = ["Push", "Pull", "Legs", "Core"];

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
        child: CircularButton(
          borderColor: Colors.grey[800],
          label: "Start/Log Workout",
          dark: true,
          color: AppColors.darkScaffoldColor,

          onTap: () async {
            print("Start/Log Workout tapped");
            showCupertinoChoiceDialog(context);
          },
        ),
      ),
      body: Column(
        children: [
          MpcHeader(
            label: "TRAINING PLAN",
            backgroundColor: AppColors.lightScaffoldColor,
            textColor: AppColors.darkTextColor,
            back: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding(context) + 50.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/training_plan.png'),
                      ),
                    ),
                  ),
                  Gap(16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upper Body Strength",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            Gap(4.h),
                            Row(
                              children: [
                                ProfileAvatar(radius: 9.w),
                                Gap(8.w),
                                Text(
                                  "Assigned by Shane",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkTextColor.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "updated 2 days ago",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkTextColor.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Gap(20.h),
                        FocusedBodyParts(),
                        Gap(20.h),
                        DaysSelector(
                          days: days,
                          onDaySelected: selectDay,
                          selectedDayIndex: selectedDayIndex,
                        ),
                        Gap(12.h),
                        ExercisesList(
                          days: days,
                          selectedDayIndex: selectedDayIndex,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCupertinoChoiceDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Upper Body Strength - Pull '),
        content: Text('Do you want to start workout or just log it?'),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Start',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Handle Option 1
              print('Option 1 selected');
            },
          ),
          CupertinoDialogAction(
            child: Text('Log', 
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Handle Option 2
              print('Option 2 selected');
            },
          ),
        ],
      );
    },
  );
}
