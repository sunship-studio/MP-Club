import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class MpcHeader extends StatelessWidget {
  MpcHeader({
    super.key,
    required this.label,
    this.backgroundColor,
    this.suffix,
    this.textColor,
    this.onBack,
    this.onSuffixTap,
    this.back = true,
  });
  bool back;
  String label;
  Color? backgroundColor;
  Widget? suffix;
  Function()? onBack;
  Function()? onSuffixTap;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightScaffoldColor,
      ),
      child: Row(
        children: [
          if (back)
            GestureDetector(
              onTap: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.only(
                  right: horizontalPadding.w,
                  left: horizontalPadding.w,
                  top: topPadding(context),
                  bottom: 10.h,
                ),
                child: Icon(
                  Coolicons.chevron_big_left,
                  size: 24.w,
                  color: textColor ?? Colors.white,
                ),
              ),
            )
          else
            SizedBox(width: horizontalPadding.w * 2 + 24.w),
          Expanded(
            child: Container(
              
              padding: EdgeInsets.only(
                bottom: 10.h,
                top: topPadding(context),
                right: suffix == null ? (horizontalPadding.w * 2 + 24.w) : 0,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (suffix != null)
            GestureDetector(
              onTap: () {
                if (onSuffixTap != null) {
                  onSuffixTap!();
                }
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(
                  left: horizontalPadding.w,
                  right: horizontalPadding.w,
                  top: topPadding(context),
                  bottom: 10.h,
                ),
                child: suffix!,
              ),
            ),
        ],
      ),
    );
  }
}
