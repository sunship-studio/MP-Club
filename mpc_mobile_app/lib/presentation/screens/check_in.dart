import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/data/models/checkin.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/calendar.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/my_checkpoints.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/check_in_card.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  GlobalKey<CalendarState> calendarKey = GlobalKey<CalendarState>();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  void onPreviousMonth() {
    if (!calendarKey.currentState!.isExpanded) {
      calendarKey.currentState!.toggleExpanded();
    }
    setState(() {
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear--;
      } else {
        selectedMonth--;
      }
    });
  }

  void onNextMonth() {
    if (!calendarKey.currentState!.isExpanded) {
      calendarKey.currentState!.toggleExpanded();
    }
    setState(() {
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear++;
      } else {
        selectedMonth++;
      }
    });
  }

  List<int> daysThatHaveCheckIns = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,

      body: Column(
        children: [
          Column(
            children: [
              MpcHeader(
                back: false,
                suffix: Icon(
                  Coolicons.info_circle_outline,
                  color: Colors.white,
                  size: 24.w,
                ),
                onSuffixTap: () => context.push('/check_in/info'),
                label: "CHECK-IN",
                backgroundColor: AppColors.darkScaffoldColor,
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  state as AuthAuthenticated;
                  daysThatHaveCheckIns = getDaysWithCheckIns(
                    state.user.checkIns,
                    selectedMonth,
                    selectedYear,
                  );
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkScaffoldColor,
                    ),
                    child: Column(
                      children: [
                        MonthSwitch(
                          selectedMonth: selectedMonth,
                          selectedYear: selectedYear,
                          onPrevious: onPreviousMonth,
                          onNext: onNextMonth,
                        ),

                        Calendar(
                          user: state.user,
                          daysThatHaveCheckIns: daysThatHaveCheckIns,
                          key: calendarKey,
                          selectedMonth: selectedMonth,
                          selectedYear: selectedYear,
                        ),

                        Gap(16.h),
                        CheckInButton(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Checkpoints(calendarKey: calendarKey),
        ],
      ),
    );
  }
}

class MonthSwitch extends StatelessWidget {
  MonthSwitch({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.selectedMonth,
    required this.selectedYear,
  });
  Function onPrevious;
  Function onNext;
  int selectedMonth;
  int selectedYear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${Constants.months[selectedMonth - 1]} $selectedYear",
              style: TextStyle(
                color: AppColors.lightTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "${Constants.weekDays[DateTime.now().weekday - 1]}, ${DateTime.now().day} ${Constants.months[DateTime.now().month - 1]}",
              style: TextStyle(
                color: AppColors.lightTextColor.withValues(alpha: 0.6),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            onPrevious();
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[200]!.withValues(alpha: 0.1),
              ),
              shape: BoxShape.circle,
              color: AppColors.darkButtonColor,
            ),
            child: Icon(
              Coolicons.chevron_big_left,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        Gap(5.w),
        GestureDetector(
          onTap: () {
            onNext();
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[200]!.withValues(alpha: 0.1),
              ),
              shape: BoxShape.circle,
              color: AppColors.darkButtonColor,
            ),
            child: Icon(
              Coolicons.chevron_big_right,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

List<int> getDaysWithCheckIns(List<CheckIn> checkIns, int month, int year) {
  return checkIns
      .where(
        (checkIn) => checkIn.date.month == month && checkIn.date.year == year,
      )
      .map((checkIn) => checkIn.date.day)
      .toList();
}
