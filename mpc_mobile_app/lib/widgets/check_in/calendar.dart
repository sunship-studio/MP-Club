import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/screens/check_in.dart';
import 'package:mpc_mobile_app/widgets/column_builder.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  bool isExpanded = false;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isExpanded)
          CalendarGrid(month: DateTime.now().month, year: DateTime.now().year)
        else if (!isExpanded)
          DaysOfTheWeek(),

        if (!isExpanded)
          NumberedDays(
            daysThatHaveCheckIns: [3, 5, 6, 8, 10, 11, 12, 15],
            currentWeek:
                _buildCalendarGrid(
                  month: DateTime.now().month,
                  year: DateTime.now().year,
                ).currentWeek,
          ),

        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isExpanded
                      ? Coolicons.chevron_big_up
                      : Coolicons.chevron_big_down,
                  size: 16,
                  color: AppColors.lightTextColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

CalendarData _buildCalendarGrid({required int month, required int year}) {
  final now = DateTime.now();
  final isViewingCurrentMonth = now.year == year && now.month == month;

  // Get first day of month (1 = Monday, 7 = Sunday)
  final firstDayOfMonth = DateTime(year, month, 1);
  final firstWeekday = firstDayOfMonth.weekday; // 1-7 (Mon-Sun)

  // Convert to Sunday-based index (0 = Sunday, 6 = Saturday)
  final sundayBasedWeekday = firstWeekday % 7; // Sunday = 0, Monday = 1, etc.

  // Get number of days in current month
  final lastDayOfMonth = DateTime(year, month + 1, 0);
  final daysInMonth = lastDayOfMonth.day;

  // Get number of days in previous month
  final prevMonth = month == 1 ? 12 : month - 1;
  final prevMonthYear = month == 1 ? year - 1 : year;
  final daysInPrevMonth = DateTime(prevMonthYear, prevMonth + 1, 0).day;

  // Next month info
  final nextMonth = month == 12 ? 1 : month + 1;
  final nextMonthYear = month == 12 ? year + 1 : year;

  List<List<CalendarDay>> weeks = [];
  List<CalendarDay> currentWeek = [];
  List<CalendarDay>? todaysWeek;

  // Add days from previous month
  int prevMonthStartDay = daysInPrevMonth - sundayBasedWeekday + 1;
  for (int i = 0; i < sundayBasedWeekday; i++) {
    currentWeek.add(
      CalendarDay(
        day: prevMonthStartDay,
        month: prevMonth,
        year: prevMonthYear,
        isCurrentMonth: false,
        isPreviousMonth: true,
      ),
    );
    prevMonthStartDay++;
  }

  // Add days of current month
  for (int day = 1; day <= daysInMonth; day++) {
    currentWeek.add(
      CalendarDay(
        day: day,
        month: month,
        year: year,
        isCurrentMonth: true,
        isPreviousMonth: false,
      ),
    );

    // If week is complete (7 days), add to weeks and start new week
    if (currentWeek.length == 7) {
      // Check if this week contains today
      if (isViewingCurrentMonth &&
          currentWeek.any(
            (d) =>
                d.year == now.year && d.month == now.month && d.day == now.day,
          )) {
        todaysWeek = List.from(currentWeek);
      }

      weeks.add(List.from(currentWeek));
      currentWeek = [];
    }
  }

  // Add days from next month
  int nextMonthDay = 1;
  if (currentWeek.isNotEmpty) {
    while (currentWeek.length < 7) {
      currentWeek.add(
        CalendarDay(
          day: nextMonthDay,
          month: nextMonth,
          year: nextMonthYear,
          isCurrentMonth: false,
          isPreviousMonth: false,
        ),
      );
      nextMonthDay++;
    }

    // Check if this last week contains today
    if (isViewingCurrentMonth &&
        currentWeek.any(
          (d) => d.year == now.year && d.month == now.month && d.day == now.day,
        )) {
      todaysWeek = List.from(currentWeek);
    }

    weeks.add(currentWeek);
  }

  return CalendarData(weeks: weeks, currentWeek: todaysWeek ?? []);
}

class CalendarGrid extends StatelessWidget {
  final int month; // 1-12
  final int year;
  List<int> daysThatHaveCheckIns = [3, 5, 6, 8, 10, 11, 12, 15];

  CalendarGrid({Key? key, required this.month, required this.year})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarGrid = _buildCalendarGrid(month: this.month, year: this.year);
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Column(
      children: [
        DaysOfTheWeek(),
        // Calendar grid
        ...calendarGrid.weeks.map(
          (week) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children:
                  week
                      .map(
                        (day) => Expanded(
                          child: Container(
                            height: 35.h,

                            decoration: BoxDecoration(
                              border: Border.all(
                                color: day.getColors(daysThatHaveCheckIns)[1],
                                width: 1.5.w,
                                strokeAlign: -1,
                              ),
                              shape: BoxShape.circle,
                              color: day.getColors(daysThatHaveCheckIns)[0],
                            ),
                            child: Center(
                              child: Text(
                                "${day.day}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarData {
  final List<List<CalendarDay>> weeks;
  final List<CalendarDay> currentWeek;

  CalendarData({required this.weeks, required this.currentWeek});
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
                      color: Colors.white,
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
  NumberedDays({
    super.key,
    required this.daysThatHaveCheckIns,
    required this.currentWeek,
  });

  final List<int> daysThatHaveCheckIns;
  final List<CalendarDay> currentWeek;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            currentWeek
                .map(
                  (day) => Expanded(
                    child: Container(
                      height: 35.h,

                      decoration: BoxDecoration(
                        border: Border.all(
                          color: day.getColors(daysThatHaveCheckIns)[1],
                          width: 1.5.w,
                          strokeAlign: -1,
                        ),
                        shape: BoxShape.circle,
                        color: day.getColors(daysThatHaveCheckIns)[0],
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class CalendarDay {
  final int day;
  final int year;
  final int month;
  final bool isCurrentMonth;
  final bool isPreviousMonth;

  CalendarDay({
    required this.day,
    required this.year,
    required this.month,
    required this.isCurrentMonth,
    required this.isPreviousMonth,
  });

  List<Color> getColors(List<int> daysThatHaveCheckIns) {
    if (isCurrentMonth && daysThatHaveCheckIns.contains(day)) {
      return [AppColors.errorColor.withValues(alpha: 0.8), Colors.transparent];
    } else if (isCurrentMonth &&
        this.day == DateTime.now().day &&
        this.month == DateTime.now().month &&
        this.year == DateTime.now().year) {
      return [AppColors.errorColor.withValues(alpha: 0.8), Colors.transparent];
    } else if (isCurrentMonth) {
      return [
        AppColors.textSubColor.withValues(alpha: 0.2),
        Colors.transparent,
      ];
    } else {
      return [
        AppColors.textSubColor.withValues(alpha: 0.06),
        Colors.transparent,
      ];
    }
  }

  bool get isNextMonth => !isCurrentMonth && !isPreviousMonth;
}
