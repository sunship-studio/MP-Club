import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/group%20classes/cubit.dart';
import 'package:mpc_admin_app/app/bloc/group%20classes/state.dart';
import 'package:mpc_admin_app/app/models/group_class.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';

class GroupClassesScreen extends StatefulWidget {
  const GroupClassesScreen({super.key});

  @override
  State<GroupClassesScreen> createState() => _GroupClassesScreenState();
}

class _GroupClassesScreenState extends State<GroupClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupClassesCubit>().loadGroupClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GroupClassesCubit, GroupClassesState>(
        builder: (context, state) {
          if (state is GroupClassesLoading) {
            return _buildLoadingState();
          } else if (state is GroupClassesError) {
            return _buildErrorState(state);
          } else if (state is GroupClassesLoaded) {
            return _buildLoadedState(state);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading group classes...',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'SF-Pro',
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(GroupClassesError state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'SF-Pro',
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SF-Pro',
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ModernButton(
              onPressed: () {
                context.read<GroupClassesCubit>().loadGroupClasses();
              },
              label: 'Retry',
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(GroupClassesLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupClassesCubit>().loadGroupClasses();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Gap(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Group Classes',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: 'SF-Pro',
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.push(RouteNames.groupClassEditor);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32.w,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  state.groupClasses.isEmpty
                      ? const EmptyState(
                        icon: Icons.class_,
                        title: 'No group classes',
                        subtitle:
                            'Create your first group class to get started',
                      )
                      : ListView.builder(
                        itemCount: state.groupClasses.length,
                        itemBuilder: (context, index) {
                          final groupClass = state.groupClasses[index];
                          return GroupClassCard(
                            groupClass: groupClass,
                            onTap: () {
                              context.push(
                                RouteNames.groupClassEditor,
                                extra: groupClass,
                              );
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder:
                                    (dialogContext) => AlertDialog(
                                      title: const Text('Delete Group Class'),
                                      content: const Text(
                                        'Are you sure you want to delete this group class?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<GroupClassesCubit>()
                                                .deleteGroupClass(
                                                  groupClass.id!,
                                                );
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onViewAttendees: () {
                              context.push(
                                RouteNames.groupClassEditor,
                                extra: groupClass,
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupClassCard extends StatelessWidget {
  final GroupClass groupClass;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onViewAttendees;

  const GroupClassCard({
    super.key,
    required this.groupClass,
    required this.onTap,
    required this.onDelete,
    required this.onViewAttendees,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpots = groupClass.timeSlots.fold<int>(
      0,
      (sum, slot) => sum + slot.spots.length,
    );
    final totalAvailable =
        groupClass.timeSlots.length * groupClass.spotsAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupClass.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'SF-Pro',
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${groupClass.durationMinutes} minutes',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'SF-Pro',
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                if (groupClass.recurring && groupClass.dayOfWeek != null) ...[
                  _InfoChip(
                    icon: Icons.repeat,
                    label: 'Recurring - ${groupClass.dayOfWeek}',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today,
                      label:
                          groupClass.recurring
                              ? 'Next: ${groupClass.date.day}/${groupClass.date.month}/${groupClass.date.year}'
                              : '${groupClass.date.day}/${groupClass.date.month}/${groupClass.date.year}',
                      color: Colors.blue,
                    ),
                    _InfoChip(
                      icon: Icons.access_time,
                      label: '${groupClass.timeSlots.length} slots',
                      color: Colors.orange,
                    ),
                    _InfoChip(
                      icon: Icons.people,
                      label: '$totalSpots/$totalAvailable',
                      color:
                          totalSpots >= totalAvailable
                              ? Colors.red
                              : Colors.green,
                    ),
                  ],
                ),
                if (totalSpots > 0) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewAttendees,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Attendees'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'SF-Pro',
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
