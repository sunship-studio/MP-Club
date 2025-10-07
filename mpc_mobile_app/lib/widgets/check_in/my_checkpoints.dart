import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/screens/check_in.dart';
import 'package:mpc_mobile_app/widgets/check_in/calendar.dart';
import 'package:mpc_mobile_app/widgets/check_in/checkpoint_card.dart';
import 'package:mpc_mobile_app/widgets/check_in/details.dart';

class Checkpoints extends StatelessWidget {
  const Checkpoints({super.key, required this.calendarKey});

  final GlobalKey<CalendarState> calendarKey;

  Future<void> _showDetailsModal(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CheckInDetails(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onVerticalDragDown: (_) {
          // Collapse calendar when dragged down
          if (calendarKey.currentState != null &&
              calendarKey.currentState!.mounted &&
              calendarKey.currentState!.isExpanded) {
            calendarKey.currentState!.toggleExpanded();
          }
        },
        onTap: () {
          // Collapse calendar when tapped
          if (calendarKey.currentState != null &&
              calendarKey.currentState!.mounted &&
              calendarKey.currentState!.isExpanded) {
            calendarKey.currentState!.toggleExpanded();
          }
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),

          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.w,
            vertical: 16.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightScaffoldColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "MY CHECKPOINTS",
                    style: TextStyle(
                      color: AppColors.darkTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "More Details",
                    style: TextStyle(
                      color: AppColors.greyTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Gap(5.h),
              Expanded(
                child: GestureDetector(
                  onVerticalDragDown: (_) {
                    // Scroll to top when tapped
                    if (calendarKey.currentState != null &&
                        calendarKey.currentState!.mounted &&
                        calendarKey.currentState!.isExpanded) {
                      calendarKey.currentState!.toggleExpanded();
                    }
                  },
                  child: ListView(
                    padding: EdgeInsets.only(top: 10.h),

                    physics: BouncingScrollPhysics(),
                    children: [
                      CheckpointCard(onTap: () => _showDetailsModal(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
