import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/workout.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/models/workout.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';
import 'package:mpc_mobile_app/presentation/widgets/profile_avatar.dart';
import 'package:mpc_mobile_app/presentation/widgets/training_plan/days_selector.dart';
import 'package:mpc_mobile_app/presentation/widgets/training_plan/exercises.dart';
import 'package:mpc_mobile_app/presentation/widgets/training_plan/focused_body_parts.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class TrainingPlanScreen extends StatefulWidget {
  const TrainingPlanScreen({super.key});

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen> {
  int selectedDayIndex = 0;
  List<String> dayNames = [];

  @override
  void initState() {
    super.initState();
  }

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          authState as AuthAuthenticated;
          User user = authState.user;
          if (user.trainingPlan.days.isEmpty) {
            return SizedBox.shrink();
          }
          return BlocListener<WorkoutCubit, WorkoutState>(
            listener: (context, state) {
              if (state is WorkoutLogged) {
                SnackBarService.show(
                  context: context,
                  message: "Workout logged successfully!",
                  isError: false,
                  isNavBar: true,
                  isFloating: true,
                );
              } else if (state is WorkoutError) {
                SnackBarService.show(
                  context: context,
                  message: state.message,
                  isError: true,
                  isNavBar: true,
                  isFloating: true,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 50.h),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              child: CircularButton(
                borderColor: Colors.grey[800],
                label: "Start/Log Workout",
                dark: true,
                color: AppColors.darkScaffoldColor,

                onTap: () async {
                  print("Start/Log Workout tapped");
                  showWorkoutDialog(context, selectedDayIndex, () {
                    context.pop();
                    final workoutDay =
                        (context.read<AuthCubit>().state as AuthAuthenticated)
                            .user
                            .trainingPlan
                            .days[selectedDayIndex];
                    context.read<WorkoutCubit>().logWorkout(
                      Workout(workout: workoutDay, date: DateTime.now()),
                      (context.read<AuthCubit>().state as AuthAuthenticated)
                          .user
                          .id,
                    );

                    print('Option 1 selected');
                  });
                },
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          MpcHeader(
            label: "TRAINING PLAN",
            backgroundColor: AppColors.lightScaffoldColor,
            textColor: AppColors.darkTextColor,
            back: false,
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              authState as AuthAuthenticated;
              User user = authState.user;
              if (user.trainingPlan.days.isEmpty) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.w,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No training plan assigned. but don't worry, your coach will assign one soon! 🫡",
                          style: TextStyle(
                            color: AppColors.darkTextColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(bottomPadding(context) + 40.h),
                      ],
                    ),
                  ),
                );
              }
              return BlocBuilder<WorkoutCubit, WorkoutState>(
                builder: (context, state) {
                  if (state is WorkoutLoading) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blueColor,
                        ),
                      ),
                    );
                  }

                  dayNames.clear();
                  for (var day in user.trainingPlan.days) {
                    dayNames.add(day.name);
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: bottomPadding(context) + 100.h,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 240.h,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  'assets/images/training_plan.png',
                                ),
                              ),
                            ),
                          ),
                          Gap(16.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.trainingPlan.name,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkTextColor,
                                      ),
                                    ),
                                    Gap(4.h),
                                    Row(
                                      children: [
                                        ProfileAvatar(radius: 9.w),
                                        Gap(8.w),
                                        Text(
                                          "Assigned by Shane",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkTextColor
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          "updated ${user.trainingPlan.lastUpdated != null ? "${user.trainingPlan.lastUpdated!.day} ${Constants.months[user.trainingPlan.lastUpdated!.month - 1]}" : "N/A"}",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkTextColor
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Gap(20.h),
                                FocusedBodyParts(
                                  bodyParts: user.trainingPlan.bodyParts!,
                                ),
                                Gap(20.h),
                                DaysSelector(
                                  days: dayNames,
                                  onDaySelected: selectDay,
                                  selectedDayIndex: selectedDayIndex,
                                ),
                                Gap(12.h),
                                ExercisesList(
                                  days: dayNames,
                                  exercises:
                                      user
                                          .trainingPlan
                                          .days[selectedDayIndex]
                                          .exercises,
                                  selectedDayIndex: selectedDayIndex,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

void showWorkoutDialog(
  BuildContext context,
  int selectedDayIndex,
  Function onLogWorkout,
) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          '${(context.read<AuthCubit>().state as AuthAuthenticated).user.trainingPlan.name}- ${(context.read<AuthCubit>().state as AuthAuthenticated).user.trainingPlan.days[selectedDayIndex].name}  ',
        ),
        content: Text('Do you want to start workout or just log it?'),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Start',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);

              context.push(
                '/training_plan/workout',
                extra:
                    (context.read<AuthCubit>().state as AuthAuthenticated)
                        .user
                        .trainingPlan
                        .days[selectedDayIndex],
              );
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'Log',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              onLogWorkout();
            },
          ),
        ],
      );
    },
  );
}
