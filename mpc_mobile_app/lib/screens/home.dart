import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/home/calories_progress.dart';
import 'package:mpc_mobile_app/widgets/home/chat_trainer_card.dart';
import 'package:mpc_mobile_app/widgets/home/check_in_card.dart';
import 'package:mpc_mobile_app/widgets/home/food_guidelines.dart';
import 'package:mpc_mobile_app/widgets/icon_button.dart';
import 'package:mpc_mobile_app/widgets/home/nutrition_box.dart';
import 'package:mpc_mobile_app/widgets/profile_avatar.dart';

import 'package:mpc_mobile_app/widgets/home/my_training_plan.dart';
import 'package:mpc_mobile_app/widgets/home/tutorials_for_you.dart';
import 'package:mpc_mobile_app/widgets/home/weight_progress.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: MpcNavBar(),

      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
              padding: EdgeInsets.only(
                top: topPadding(context) + 16.h,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 25.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Monday, 12 Sep",
                            style: TextStyle(
                              color: AppColors.greyTextColor.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Hey, Igor Kamrowski!",
                            style: TextStyle(
                              color: AppColors.lightTextColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ProfileAvatar(radius: 18.h),
                    ],
                  ),
                  SizedBox(height: verticalPadding),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatTrainerCard(),
                        Gap(10),
                        Row(
                          children: [
                            WeightProgress(),
                            Gap(10),
                            CaloriesProgress(),
                          ],
                        ),
                        Gap(10),
                        CheckInCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(25.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              margin: EdgeInsets.only(bottom: bottomPadding(context)),
              child: Column(
                children: [
                  FoodGuidelines(),
                  Gap(24.h),
                  MyTrainingPlan(),
                  Gap(24.h),
                  Column(
                    children: [
                      Row(
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
                      Gap(10.h),
                      TutorialsForYou(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MpcNavBar extends StatefulWidget {
  const MpcNavBar({super.key});

  @override
  State<MpcNavBar> createState() => _MpcNavBarState();
}

class _MpcNavBarState extends State<MpcNavBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Your app background color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.r),
              color: Colors.white, // Nav bar background (not transparent)
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  isSelected: selectedIndex == 0,
                  iconName: 'home',
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: selectedIndex == 1,
                  iconName: 'movie',
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: selectedIndex == 2,
                  iconName: 'barbell',
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  onTap: () {
                    setState(() {
                      selectedIndex = 4;
                    });
                  },
                  iconName: 'checklist',
                  isSelected: selectedIndex == 4,
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: selectedIndex == 3,
                  iconName: 'soup',
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                ),
                // ... more nav items
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom - 5),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  NavBarItem({
    super.key,
    this.isSelected = true,
    this.iconName = 'home',
    required this.onTap,
  });
  Function() onTap;
  bool isSelected;
  String iconName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              isSelected
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withAlpha(255),
                      Colors.grey[600]!.withAlpha(205),
                    ],
                  )
                  : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/$iconName.svg',
            width: 20.w,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : AppColors.greyTextColor,
              BlendMode.srcIn,
            ),
            height: 20.h,
          ),
        ),
      ),
    );
  }
}
