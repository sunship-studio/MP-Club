import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';

class TutorialBox extends StatefulWidget {
  const TutorialBox({super.key, required this.exercise});
  final Exercise exercise;
  @override
  State<TutorialBox> createState() => _TutorialBoxState();
}

class _TutorialBoxState extends State<TutorialBox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/tutorial/', extra: widget.exercise);
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
        scale: _isPressed ? 0.98 : 1.0,
        child: Container(
          padding: EdgeInsets.all(16.w),
          width: 270.w,
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: NetworkImage(widget.exercise.imageUrl),
              fit: BoxFit.cover,
              alignment: Alignment(0, -0.4), //   Move image up slightly
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: -0.4,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      "${Constants.formatDuration(Duration(seconds: widget.exercise.videoLengthSeconds))} mins",
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withAlpha(0),
                        Colors.white.withAlpha(200),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Coolicons.play_arrow,
                    size: 16.h,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
