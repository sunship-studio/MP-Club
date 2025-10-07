import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class CheckpointCard extends StatefulWidget {
  CheckpointCard({super.key, required this.onTap});
  Function? onTap;
  @override
  State<CheckpointCard> createState() => _MyCheckpointCardState();
}

class _MyCheckpointCardState extends State<CheckpointCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => setState(() {
            _isPressed = !_isPressed;
            if (widget.onTap != null) {
              widget.onTap!();
            }
          }),
      onTapDown:
          (details) => setState(() {
            _isPressed = true;
          }),
      onTapUp:
          (details) => setState(() {
            _isPressed = false;
          }),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16.w),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                "assets/images/tutorial.png",
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "4 October",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: AppColors.darkTextColor,
                    ),
                  ),
                  Gap(4.h),
                  Container(
                    width: double.infinity,
                    child: Text(
                      "“Slept well, and feeling more stronger than last week 💪”",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        color: AppColors.greyTextColor,
                      ),
                      maxLines: 3,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "165",
                  style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 18.sp,
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
                    color: AppColors.greyTextColor.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
