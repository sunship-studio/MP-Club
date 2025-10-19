import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

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
