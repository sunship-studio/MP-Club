import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class TutorialsForYou extends StatelessWidget {
  const TutorialsForYou({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Text(
                "Tutotials for you",
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
            children: [TutorialBox(), Gap(10.w), TutorialBox()],
          ),
        ),
      ],
    );
  }
}

class TutorialBox extends StatefulWidget {
  const TutorialBox({super.key});

  @override
  State<TutorialBox> createState() => _TutorialBoxState();
}

class _TutorialBoxState extends State<TutorialBox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/tutorial/1');
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
            color: AppColors.lightScaffoldColor,
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: AssetImage('assets/images/tutorial.png'),
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
                      "How To: Squats",
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
                      "12.41",
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
