import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';

class CheckInCard extends StatelessWidget {
  CheckInCard({super.key});

  List<String> days = const ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Check-In",
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          DaysOfTheWeek(),
          NumberedDays(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16.h),
            width: double.infinity,
            height: 1.h,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7.r),
                child: Image.asset(
                  "assets/images/checkin.png",
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                ),
              ),

              Gap(16.w),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "165",
                              style: TextStyle(
                                color: AppColors.lightTextColor,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                letterSpacing: -1.8,
                                height: 1,
                              ),
                            ),
                            Gap(4),
                            Text(
                              "lbs",
                              style: TextStyle(
                                color: AppColors.greyTextColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          "2 Oct",
                          style: TextStyle(
                            color: AppColors.greyTextColor.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    Text(
                      "“Slept well, and feeling more stronger than last week 💪”",
                      style: TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CheckInButton(),
        ],
      ),
    );
  }
}

class DaysOfTheWeek extends StatelessWidget {
  DaysOfTheWeek({super.key});
  List<String> days = const ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      child: Row(
        children: [
          for (var day in days)
            Expanded(
              child: Container(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: AppColors.greyTextColor.withValues(alpha: 0.6),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NumberedDays extends StatelessWidget {
  NumberedDays({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Container(
                height: 35.h,

                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        i == DateTime.now().weekday % 7
                            ? AppColors.redColor
                            : Colors.transparent,
                    width: 1.5.w,
                    strokeAlign: -1,
                  ),
                  shape: BoxShape.circle,
                  color:
                      i == DateTime.now().weekday % 7
                          ? Colors.transparent
                          : i < DateTime.now().weekday % 7
                          ? AppColors.errorColor
                          : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    DateTime.now().weekday == i
                        ? DateTime.now().day.toString()
                        : DateTime.now()
                            .subtract(
                              Duration(days: DateTime.now().weekday - i),
                            )
                            .day
                            .toString(),
                    style: TextStyle(
                      color:
                          i == DateTime.now().weekday % 7
                              ? AppColors.redColor
                              : i < DateTime.now().weekday % 7
                              ? Colors.white
                              : AppColors.greyTextColor.withValues(alpha: 0.6),
                      fontSize: 11.sp,
                      fontWeight:
                          DateTime.now().weekday == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckInButton extends StatefulWidget {
  CheckInButton({super.key});

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {});
      },
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapUp: (details) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.darkButtonColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.grey[200]!.withValues(alpha: 0.07),
              width: 1.5,
              strokeAlign: -1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.0),
                blurRadius: _isPressed ? 4 : 8,
                offset: Offset(0, _isPressed ? 1 : 2),
              ),
            ],
          ),
          child: Text(
            "Check In Now",
            style: TextStyle(
              color: AppColors.lightTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
