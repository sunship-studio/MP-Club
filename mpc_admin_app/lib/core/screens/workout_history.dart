import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/models/User.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key, required this.user});

  final User user;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${user.firstName.toUpperCase()} WORKOUT HISTORY',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          Gap(8.h),
          if (user.doneWorkouts.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No workouts logged yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'SF-Pro',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: user.doneWorkouts.length,
                itemBuilder: (context, index) {
                  final workout =
                      user.doneWorkouts[user.doneWorkouts.length - 1 - index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        workout.workout.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'SF-Pro',
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(workout.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'SF-Pro',
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children:
                          workout.workout.exercises.map((exercise) {
                            return Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                left: 12.w,
                                right: 12.w,
                                bottom: 10.h,
                              ),
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'SF-Pro',
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Gap(6.h),
                                  ...List.generate(exercise.sets?.length ?? 0, (
                                    setIndex,
                                  ) {
                                    final set = exercise.sets![setIndex];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 3.h),
                                      child: Text(
                                        'Set ${setIndex + 1}: ${set.reps} reps • ${set.weight} kg • RIR ${set.rir}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'SF-Pro',
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
