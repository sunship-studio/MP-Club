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
          label: "Start Workout",
          dark: true,
          color: AppColors.darkScaffoldColor,

          onTap: () async {},
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

class DaysSelector extends StatelessWidget {
  DaysSelector({
    super.key,
    this.selectedDayIndex = 0,
    required this.onDaySelected,
    required this.days,
  });
  List<String> days;
  int selectedDayIndex;
  Function(int index) onDaySelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "WORKOUT DAY SELECTION",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
              letterSpacing: -0.4,
            ),
          ),
          Gap(10.h),
          Row(
            children: [
              for (var day in days)
                DaySelector(
                  index: days.indexOf(day),
                  selectedIndex: selectedDayIndex,
                  onTap: () {
                    if (onDaySelected != null) {
                      onDaySelected!(days.indexOf(day));
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class FocusedBodyParts extends StatelessWidget {
  const FocusedBodyParts({super.key});

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
            rowSizes: repeat(3, [auto]), // 3 rows with auto height
            rowGap: 8.h,

            children: [
              BodyPart(label: "Shoulders"),
              BodyPart(label: "Back"),
              BodyPart(label: "Biceps"),
              BodyPart(label: "Chest"),
              BodyPart(label: "Triceps"),
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

class DaySelector extends StatefulWidget {
  DaySelector({
    super.key,
    required this.index,
    this.selectedIndex = 0,
    this.onTap,
  });
  int index;
  int selectedIndex;
  Function()? onTap;

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _isPressed ? 0.95 : 1.0,
          child: Container(
            margin: EdgeInsets.only(right: 8.w),

            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color:
                  widget.selectedIndex == widget.index
                      ? Colors.white
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color:
                    widget.index == widget.selectedIndex
                        ? AppColors.darkTextColor.withValues(alpha: 0.9)
                        : AppColors.darkTextColor.withValues(alpha: 0.1),
                width: 1.w,
              ),
            ),
            child: Center(
              child: Text(
                "Day ${widget.index + 1}",
                style: TextStyle(
                  color:
                      widget.index == widget.selectedIndex
                          ? AppColors.darkTextColor
                          : AppColors.darkTextColor.withValues(alpha: 0.5),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
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
