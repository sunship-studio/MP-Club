import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/check_in.dart';
import 'package:mpc_mobile_app/data/models/checkin.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/repositories/check_in.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/calendar.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/checkpoint_card.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/details.dart';

class Checkpoints extends StatelessWidget {
  const Checkpoints({super.key, required this.calendarKey});

  final GlobalKey<CalendarState> calendarKey;

  Future<void> _showDetailsModal(
    BuildContext context,
    CheckIn checkIn,
    User user,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder:
            (context) => BlocProvider(
              create: (context) => CheckInCubit(getIt<CheckInRepository>()),
              child: CheckInDetails(checkIn: checkIn, user: user),
            ),
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
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      state as AuthAuthenticated;
                      if (state.user.checkIns.isEmpty) {
                        return Center(
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: bottomPadding(context),
                            ),
                            child: Text(
                              "No checkpoints available. Start logging your progress! 🏋📈",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.darkTextColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 16.h),
                        itemCount: state.user.checkIns.length,
                        itemBuilder: (context, index) {
                          final checkIn =
                              state.user.checkIns.reversed.toList()[index];
                          return CheckpointCard(
                            onTap: () {
                              _showDetailsModal(context, checkIn, state.user);
                            },
                            checkIn: checkIn,
                          );
                        },
                      );
                    },
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
