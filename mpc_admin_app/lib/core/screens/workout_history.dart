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

  /// Parses the low end of a target reps range like "8-12" or "10".
  int? _lowEnd(String reps) {
    final trimmed = reps.trim();
    if (trimmed.isEmpty) return null;
    final dash = RegExp(r'[-–—]');
    final parts = trimmed.split(dash);
    return int.tryParse(parts.first.trim());
  }

  /// A set "met target" if actualReps is null (blank = met) or
  /// actualReps >= low end of the target range.
  bool _setMetTarget(int? actualReps, String targetReps) {
    if (actualReps == null) return true;
    final low = _lowEnd(targetReps);
    if (low == null) return true;
    return actualReps >= low;
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

                  // Per-workout summary: count met vs total across all sets.
                  int totalSets = 0;
                  int metSets = 0;
                  for (final ex in workout.workout.exercises) {
                    for (final s in ex.sets ?? []) {
                      totalSets++;
                      if (_setMetTarget(s.actualReps, s.reps)) metSets++;
                    }
                  }

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
                      subtitle: Row(
                        children: [
                          Text(
                            _formatDate(workout.date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'SF-Pro',
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: (metSets == totalSets
                                      ? Colors.green
                                      : Colors.orange)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '$metSets/$totalSets sets met target',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontFamily: 'SF-Pro',
                                color: metSets == totalSets
                                    ? Colors.green[700]
                                    : Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                                    final met = _setMetTarget(
                                      set.actualReps,
                                      set.reps,
                                    );
                                    final String statusLabel;
                                    final Color statusColor;
                                    if (set.actualReps == null) {
                                      statusLabel = 'Met Target';
                                      statusColor = Colors.green[700]!;
                                    } else if (met) {
                                      statusLabel = 'Met Target ✓';
                                      statusColor = Colors.green[700]!;
                                    } else {
                                      statusLabel = 'Under target ✗';
                                      statusColor = Colors.red[700]!;
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 50.w,
                                            child: Text(
                                              'Set ${setIndex + 1}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: 'SF-Pro',
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontFamily: 'SF-Pro',
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                children: [
                                                  if (set.actualReps != null) ...[
                                                    TextSpan(
                                                      text: '${set.actualReps}',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: met
                                                            ? Colors.green[700]
                                                            : Colors.red[700],
                                                      ),
                                                    ),
                                                    TextSpan(
                                                        text:
                                                            '/${set.reps} reps'),
                                                  ] else
                                                    TextSpan(
                                                        text:
                                                            '${set.reps} reps (target hit)'),
                                                  TextSpan(
                                                      text:
                                                          '  •  ${set.weight} kg  •  RIR ${set.rir}'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontFamily: 'SF-Pro',
                                              color: statusColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
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
