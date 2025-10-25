import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/data/models/checkin.dart';
import 'package:mpc_mobile_app/presentation/screens/check_in.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/calendar.dart';
import 'package:mpc_mobile_app/routes/main.dart';

class CheckInCard extends StatelessWidget {
  CheckInCard({super.key});

  List<String> days = const ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navBarKey.currentState?.switchPage(3),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          state as AuthAuthenticated;
          List<int> daysThatHaveCheckIns = getDaysWithCheckIns(
            state.user.checkIns,
            DateTime.now().month,
            DateTime.now().year,
          );

          CheckIn lastCheckIn = (state.user.checkIns as List<CheckIn>).last;

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
                NumberedDays(
                  currentWeek:
                      buildCalendarGrid(
                        month: DateTime.now().month,
                        year: DateTime.now().year,
                      ).currentWeek,
                  daysThatHaveCheckIns: daysThatHaveCheckIns,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  width: double.infinity,
                  height: 1.h,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...[
                      if (lastCheckIn.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7.r),
                          child: Image.network(
                            lastCheckIn.imageUrl!,
                            width: 100.w,
                            height: 100.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (lastCheckIn.imageUrl != null) Gap(16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      lastCheckIn.weight.toStringAsFixed(0),
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
                                      "kg",
                                      style: TextStyle(
                                        color: AppColors.greyTextColor
                                            .withValues(alpha: 0.6),
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
                                  "${lastCheckIn.date.day} ${Constants.shortMonths[lastCheckIn.date.month - 1]}",
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
                              lastCheckIn.note ?? "No notes added.",
                              style: TextStyle(
                                color: AppColors.lightTextColor,
                                fontSize: 11.sp,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.h),
                CheckInButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DaysOfTheWeek extends StatelessWidget {
  DaysOfTheWeek({super.key});
  List<String> days = const ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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

class CheckInButton extends StatefulWidget {
  const CheckInButton({super.key});

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        navBarKey.currentState?.switchPage(3);

        context.push('/check_in/submit');
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
