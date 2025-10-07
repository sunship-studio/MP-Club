import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/column_builder.dart';
import 'package:mpc_mobile_app/widgets/header.dart';

class CheckInInfo extends StatelessWidget {
  CheckInInfo({super.key});

  List<Map<String, String>> infoPoint = [
    {
      "title": "📸 Upload Progress Photos",
      "description":
          "Take or upload a photo to track physical changes over time.",
    },
    {
      "title": "⚖️ Update Weight",
      "description": "Enter your current body weight in lbs or kg.",
    },
    {
      "title": "📝 Add Notes",
      "description":
          "Share how you’re feeling, recovery updates, or any challenges.",
    },
    {
      "title": "📊 Track History",
      "description": "View past check-ins and see your progress trend.",
    },
  ];

  List<String> benefits = [
    "Helps your trainer adjust your workout and nutrition plan.",
    "Keeps you accountable to your goals.",
    "Creates a clear visual and data-based record of your progress.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MpcHeader(
            label: "CHECK-IN INFO",
            backgroundColor: AppColors.darkScaffoldColor,
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  top: 24.h,
                  bottom: 10.h + bottomPadding(context),
                ),

                children: [
                  Text(
                    "About Check-Ins",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(10.h),
                  Text(
                    "Check-ins help you and your trainer stay aligned on progress. Use this page to update your stats and share your journey",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(24.h),
                  Text(
                    "What You Can Do Here:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(24.h),
                  ColumnBuilder(
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 24.h),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${(index + 1).toString()}.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Gap(8.w),
                                Text(
                                  infoPoint[index]['title']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Gap(6.h),
                            Container(
                              padding: EdgeInsets.only(left: 20.w),
                              child: Text(
                                infoPoint[index]['description']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16.sp,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: infoPoint.length,
                  ),
                  Gap(8.h),
                  Text(
                    "Why It’s Important",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(10.h),
                  ColumnBuilder(
                    itemBuilder: (context, state) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "• ",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(4.w),
                            Expanded(
                              child: Text(
                                benefits[state],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16.sp,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: benefits.length,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
