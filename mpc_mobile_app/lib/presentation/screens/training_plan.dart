import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/workout.dart';
import 'package:mpc_mobile_app/data/models/TrainingDay.dart';
import 'package:mpc_mobile_app/data/models/UserExercise.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/models/workout.dart';
import 'package:mpc_mobile_app/data/repositories/workout_weight_prefs.dart';
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
  List<TrainingDay> _editableDays = [];
  String? _editableUserId;
  String? _appliedOverridesKey;
  late final WorkoutWeightPrefsRepository _weightPrefsRepository;

  @override
  void initState() {
    super.initState();
    _weightPrefsRepository = getIt<WorkoutWeightPrefsRepository>();
  }

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
    });
  }

  void _syncEditableDays(User user) {
    final shouldReset =
        _editableUserId != user.id ||
        _editableDays.length != user.trainingPlan.days.length;

    if (!shouldReset) {
      return;
    }

    _editableDays =
        user.trainingPlan.days.map((day) => day.deepCopy()).toList();
    _editableUserId = user.id;

    if (_editableDays.isEmpty) {
      selectedDayIndex = 0;
      return;
    }

    if (selectedDayIndex >= _editableDays.length) {
      selectedDayIndex = 0;
    }

    _applySavedWeightsIfNeeded(user);
  }

  String _exerciseKey(UserExercise exercise, int exerciseIndex) {
    final base = (exercise.id ?? exercise.name).trim();
    return '${base}_$exerciseIndex';
  }

  Future<void> _applySavedWeightsIfNeeded(User user) async {
    final key = '${user.id}_${user.trainingPlan.name}';
    if (_appliedOverridesKey == key) {
      return;
    }

    _appliedOverridesKey = key;
    final overrides = await _weightPrefsRepository.getOverrides(
      userId: user.id,
      trainingPlanName: user.trainingPlan.name,
    );

    if (!mounted || overrides.isEmpty || _editableUserId != user.id) {
      return;
    }

    setState(() {
      for (var dayIndex = 0; dayIndex < _editableDays.length; dayIndex++) {
        final dayData =
            (overrides[dayIndex.toString()] as Map?)?.cast<String, dynamic>();
        if (dayData == null) {
          continue;
        }

        final day = _editableDays[dayIndex];
        for (
          var exerciseIndex = 0;
          exerciseIndex < day.exercises.length;
          exerciseIndex++
        ) {
          final exercise = day.exercises[exerciseIndex];
          final sets = exercise.sets;
          if (sets == null || sets.isEmpty) {
            continue;
          }

          final exerciseData =
              (dayData[_exerciseKey(exercise, exerciseIndex)] as Map?)
                  ?.cast<String, dynamic>();
          if (exerciseData == null) {
            continue;
          }

          for (var setIndex = 0; setIndex < sets.length; setIndex++) {
            final override = exerciseData[setIndex.toString()];
            if (override is int) {
              sets[setIndex] = sets[setIndex].copyWith(weight: override);
            } else if (override is String) {
              final parsed = int.tryParse(override);
              if (parsed != null) {
                sets[setIndex] = sets[setIndex].copyWith(weight: parsed);
              }
            }
          }
        }
      }
    });
  }

  Future<void> _persistDayWeights({
    required User user,
    required int dayIndex,
    required TrainingDay day,
  }) {
    return _weightPrefsRepository.saveTrainingDay(
      userId: user.id,
      trainingPlanName: user.trainingPlan.name,
      dayIndex: dayIndex,
      day: day,
      exerciseKeyBuilder:
          (exerciseIndex) =>
              _exerciseKey(day.exercises[exerciseIndex], exerciseIndex),
    );
  }

  void _onWeightChanged(int exerciseIndex, int setIndex, int newWeight) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      return;
    }

    final user = authState.user;
    final day = _editableDays[selectedDayIndex];
    final sets = day.exercises[exerciseIndex].sets;

    if (sets == null || setIndex >= sets.length) {
      return;
    }

    setState(() {
      sets[setIndex] = sets[setIndex].copyWith(weight: newWeight);
    });

    _weightPrefsRepository.setWeight(
      userId: user.id,
      trainingPlanName: user.trainingPlan.name,
      dayIndex: selectedDayIndex,
      exerciseKey: _exerciseKey(day.exercises[exerciseIndex], exerciseIndex),
      setIndex: setIndex,
      weight: newWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          authState as Authenticated;
          final user = authState.user;

          _syncEditableDays(user);

          if (user.trainingPlan.days.isEmpty || _editableDays.isEmpty) {
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
                  final workoutDay = _editableDays[selectedDayIndex].deepCopy();

                  showWorkoutDialog(
                    context: context,
                    trainingPlanName: user.trainingPlan.name,
                    dayName: workoutDay.name,
                    onStartWorkout: () async {
                      final workoutCubit = context.read<WorkoutCubit>();
                      final result = await context.push(
                        '/training_plan/workout',
                        extra: workoutDay.deepCopy(),
                      );

                      if (!mounted) {
                        return;
                      }

                      if (result is TrainingDay) {
                        _editableDays[selectedDayIndex] = result.deepCopy();
                        await _persistDayWeights(
                          user: user,
                          dayIndex: selectedDayIndex,
                          day: _editableDays[selectedDayIndex],
                        );

                        if (!mounted) {
                          return;
                        }

                        workoutCubit.logWorkout(
                          Workout(workout: result, date: DateTime.now()),
                          user.id,
                        );
                      }
                    },
                    onLogWorkout: () {
                      _persistDayWeights(
                        user: user,
                        dayIndex: selectedDayIndex,
                        day: _editableDays[selectedDayIndex],
                      );
                      context.read<WorkoutCubit>().logWorkout(
                        Workout(
                          workout: _editableDays[selectedDayIndex].deepCopy(),
                          date: DateTime.now(),
                        ),
                        user.id,
                      );
                    },
                  );
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
              authState as Authenticated;
              final user = authState.user;

              _syncEditableDays(user);

              if (user.trainingPlan.days.isEmpty || _editableDays.isEmpty) {
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

                  dayNames = _editableDays.map((day) => day.name).toList();

                  return Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: bottomPadding(context) + 100.h,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 240.h,
                            width: double.infinity,
                            child: Image.network(
                              user.trainingPlan.backgroundImage,
                              fit: BoxFit.cover,
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
                                      _editableDays[selectedDayIndex].exercises,
                                  selectedDayIndex: selectedDayIndex,
                                  onWeightChanged: _onWeightChanged,
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

void showWorkoutDialog({
  required BuildContext context,
  required String trainingPlanName,
  required String dayName,
  required Future<void> Function() onStartWorkout,
  required VoidCallback onLogWorkout,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('$trainingPlanName- $dayName'),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await onStartWorkout();
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
              Navigator.of(context).pop();
              onLogWorkout();
            },
          ),
        ],
      );
    },
  );
}
