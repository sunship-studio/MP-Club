import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/calories.dart';
import 'package:mpc_mobile_app/data/models/calories_log.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/presentation/widgets/calories/add_calories.dart';
import 'package:mpc_mobile_app/presentation/widgets/calories/recent_log.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class CaloriesScreen extends StatelessWidget {
  CaloriesScreen({super.key});

  List<Map<String, dynamic>> recentLogs = [
    {"title": "Breakfast", "calories": 500, "time": "8:00 AM"},
    {"title": "Lunch", "calories": 700, "time": "12:30 PM"},
    {"title": "Snack", "calories": 200, "time": "3:00 PM"},

    {"title": "Dinner", "calories": 600, "time": "7:00 PM"},

    {"title": "Dinner", "calories": 600, "time": "7:00 PM"},
  ];

  int getUserTodayCalories(User user) {
    DateTime today = DateTime.now();
    int total = 0;
    for (var log in user.caloriesLogs) {
      if (log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day) {
        total += log.calories;
      }
    }
    return total;
  }

  List<CaloriesLog> getUserRecentLogs(User user) {
    DateTime today = DateTime.now();
    List<CaloriesLog> logs = [];
    for (var log in user.caloriesLogs.reversed) {
      if (logs.length >= 5) break;
      logs.add(log);
    }
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CaloriesCubit, CaloriesState>(
        listener: (context, state) {
          if (state is CaloriesError) {
            SnackBarService.show(
              context: context,
              message: state.message,
              isError: true,
              isNavBar: true,
            );
          } else if (state is CaloriesSuccess) {
            context.read<AuthCubit>().loadUser();
            SnackBarService.show(
              context: context,
              message: "Calories logged successfully!",
              isNavBar: true,
            );
          }
        },
        child: BlocBuilder<CaloriesCubit, CaloriesState>(
          builder: (context, state) {
            if (state is CaloriesLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.blueColor),
              );
            }
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                state as AuthAuthenticated;
                return Column(
                  children: [
                    MpcHeader(
                      back: false,
                      label: "CALORIES",
                      backgroundColor: AppColors.darkScaffoldColor,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkScaffoldColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkCardColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Calories in",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/fire.svg",
                                  width: 25.w,
                                  height: 25.h,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${getUserTodayCalories(state.user)}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          "kcal",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          "Max ${state.user.caloriesPerDay} kcal",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            LinearProgressIndicator(
                              value:
                                  (getUserTodayCalories(state.user) ?? 0) /
                                  (state.user.caloriesPerDay ?? 2000),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              color: AppColors.errorColor,
                              minHeight: 3.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding.w,
                        ),

                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AddCalories(userId: state.user.id),
                              Gap(20.h),
                              RecentLog(
                                recentLogs: getUserRecentLogs(state.user),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
