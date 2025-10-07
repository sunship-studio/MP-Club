import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class MyTrainingPlan extends StatelessWidget {
  const MyTrainingPlan({super.key});

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
            Spacer(),
            Text(
              "See All",
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
        TrainingPlanThumbnail(),
      ],
    );
  }
}

class TrainingPlanThumbnail extends StatefulWidget {
  const TrainingPlanThumbnail({super.key});

  @override
  State<TrainingPlanThumbnail> createState() => _TrainingPlanThumbnailState();
}

class _TrainingPlanThumbnailState extends State<TrainingPlanThumbnail> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Upper Body Strength",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: -0.4,
                      ),
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        Text(
                          "70%",
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            letterSpacing: -0.4,
                          ),
                        ),
                        Gap(6.w),
                        Container(
                          width: 120.w,
                          child: LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.white
                                .withAlpha(100)
                                .withAlpha(50),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
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
  StartButton({super.key});

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
