import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/calories_progress.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/chat_trainer_card.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/check_in_card.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/my_training_plan.dart';
import 'package:mpc_mobile_app/presentation/widgets/home/weight_progress.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/presentation/widgets/tutorials_for_you.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: BlocProvider.of<AuthCubit>(context)..loadUser(),
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkScaffoldColor,
                      ),
                      padding: EdgeInsets.only(
                        top: 250.h,
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: 250.h,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.lightScaffoldColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 100.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkScaffoldColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AuthAuthenticated) {
              final user = state.user;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkScaffoldColor,
                    ),
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
                                  "${Constants.weekDays[DateTime.now().weekday - 1]}, ${DateTime.now().day} ${Constants.months[DateTime.now().month - 1]}",
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
                                  "Hey, ${user.firstName.replaceAll(' ', '')} ${user.lastName.replaceAll(' ', '')} !",
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
                            ProfileAvatar(
                              user: user,
                              radius: 18.h,
                              onTap: () {
                                context.push('/home/profile');
                              },
                            ),
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
                                  WeightProgress(user: user),
                                  Gap(10),
                                  CaloriesProgress(user: user),
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
                    margin: EdgeInsets.only(bottom: bottomPadding(context)),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding.w,
                          ),
                          child: MyTrainingPlan(
                            trainingPlan: user.trainingPlan,
                          ),
                        ),
                        Gap(24.h),
                        TutorialsForYou(),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
