import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/routes/auth.dart';
import 'package:mpc_mobile_app/routes/main.dart';

import 'package:mpc_mobile_app/services/first_time.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';

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
      "title": "Your personal fitness companion",
      "description":
          "Track progress, follow meal plans, and stay connected with your coach.",
    },
  ];
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: FutureBuilder(
        future: FirstTimeService.isFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == false) {
            // Not first time, navigate to login
            Future.microtask(() => getIt<AuthRouter>().router.push('/login'));
            return SizedBox.shrink(); // Return empty widget while navigating
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Spacer(),
              Container(
                padding: EdgeInsets.only(
                  left: 25.w,
                  right: 25.w,
                  top: 24.h,
                  bottom: 24.h + bottomPadding(context),
                ),
                decoration: BoxDecoration(color: AppColors.lightScaffoldColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(height: 11.h), // Fixed: added .h for consistency
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

                    // Added: Spacer or image area
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            height: 4.h,
                            width: 16.w,
                            decoration: BoxDecoration(
                              color:
                                  currentPage == index
                                      ? AppColors.darkTextColor
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fixed: Added Expanded to buttons
                    Row(
                      children: [
                        Expanded(
                          child: CircularButton(
                            label: "Skip",
                            dark: false,
                            onTap: () async {
                              FirstTimeService.setNotFirstTime();
                              getIt<AuthRouter>().router  .push('/login');
                            },
                          ),
                        ),
                        SizedBox(width: 12.w), // Fixed: added .w
                        Expanded(
                          child: CircularButton(
                            label:
                                currentPage == pages.length - 1
                                    ? "Get Started"
                                    : "Next",
                            color: AppColors.darkScaffoldColor,
                            onTap: () async {
                              setState(() {
                                if (currentPage < pages.length - 1) {
                                  currentPage++;
                                } else {
                                  FirstTimeService.setNotFirstTime();
                                  getIt<AuthRouter>().router.go('/login');
                                }
                              });
                            },
                            dark: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
