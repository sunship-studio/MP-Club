import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Map<String, String>> pages = [
    {
      "title": "WORKOUTS, TAILORED FOR YOU",
      "description":
          "Get customized training plans, log sets and reps, and track your performance with every workout.",
    },
    {
      "title": "Stay on Track with Nutrition",
      "description":
          "Follow calorie guidelines, log meals, and check in with progress directly to your trainer.",
    },
    {
      "title": "Your personal fitness companion ",
      "description":
          "Track progress, follow meal plans, and stay connected with your coach.",
    },
  ];
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 25.w,
              right: 25.w,
              top: 24.h,
              bottom: 24.h + bottomPadding(context),
            ),
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.lightScaffoldColor2),
            child: Column(
              children: [
                Text(
                  pages[currentPage]['title']!.toUpperCase(),

                  style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 11),
                Text(
                  pages[currentPage]['description']!,
                  style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 16,
                        decoration: BoxDecoration(
                          color:
                              currentPage == 0
                                  ? AppColors.darkTextColor
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        height: 4,
                        width: 16,
                        decoration: BoxDecoration(
                          color:
                              currentPage == 1
                                  ? AppColors.darkTextColor
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      Container(
                        height: 4,
                        width: 16,
                        decoration: BoxDecoration(
                          color:
                              currentPage == 2
                                  ? AppColors.darkTextColor
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    CircularButton(
                      label: "Skip",
                      dark: false,
                      onTap: () {
                        // **
                        // Navigate to another screen or perform an action
                        // **
                      },
                    ),
                    const SizedBox(width: 12),
                    CircularButton(
                      label: "Next",
                      dark: true,
                      onTap:
                          () => setState(() {
                            if (currentPage < pages.length - 1) {
                              currentPage++;
                            } else {
                              // **
                              // Navigate to another screen or perform an action
                              // **
                            }
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
