import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/TrainingPlan.dart';
import 'package:mpc_mobile_app/routes/main.dart';

class MyTrainingPlan extends StatelessWidget {
  MyTrainingPlan({super.key, required this.trainingPlan});
  TrainingPlan trainingPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "My Training Plan",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
                color: AppColors.darkTextColor,
              ),
            ),
          ],
        ),
        Gap(10.h),
        TrainingPlanThumbnail(plan: trainingPlan),
      ],
    );
  }
}

class TrainingPlanThumbnail extends StatefulWidget {
  TrainingPlanThumbnail({super.key, required this.plan});
  TrainingPlan plan;

  @override
  State<TrainingPlanThumbnail> createState() => _TrainingPlanThumbnailState();
}

class _TrainingPlanThumbnailState extends State<TrainingPlanThumbnail> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navBarKey.currentState?.switchPage(1);
      },
      onTapDown:
          (details) => setState(() {
            _isPressed = true;
          }),
      onTapUp:
          (details) => setState(() {
            _isPressed = false;
          }),
      onTapCancel:
          () => setState(() {
            _isPressed = false;
          }),
      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.995 : 1.0,
        child: Container(
          padding: EdgeInsets.all(16.w),
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.lightScaffoldColor,
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: AssetImage('assets/images/training_plan.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: -0.4,
                  ),
                ),
                Spacer(),
                StartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartButton extends StatefulWidget {
  const StartButton({super.key});

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      onTapDown:
          (details) => setState(() {
            _isPressed = true;
          }),
      onTapUp:
          (details) => setState(() {
            _isPressed = false;
          }),
      onTapCancel:
          () => setState(() {
            _isPressed = false;
          }),
      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.94 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[100]!.withValues(alpha: 0.10),
            ),
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Text(
                "Start",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.3,
                ),
              ),
              Gap(2.w),
              Icon(Coolicons.chevron_right, color: Colors.white, size: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
