import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/state.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/exercise_card.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';

class UserPlanEditorScreen extends StatefulWidget {
  final User user;

  const UserPlanEditorScreen({super.key, required this.user});

  @override
  State<UserPlanEditorScreen> createState() => _UserPlanEditorScreenState();
}

class _UserPlanEditorScreenState extends State<UserPlanEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _animationController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDay = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrainingPlanCubit, TrainingPlanState>(
        builder: (context, state) {
          if (state is TrainingPlanError) {
            return _buildErrorState(state);
          } else if (state is TrainingPlanEditing ||
              state is TrainingPlanSearchingExercises) {
            return _buildEditorContent(state);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildErrorState(TrainingPlanError state) {
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
                context.read<TrainingPlanCubit>().savePlan(widget.user);
                context.push(RouteNames.onlineCoaching);
              },
              label: 'Retry',
              icon: Icons.refresh,
            ),
          ],
        ),
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
            'Loading your plan...',
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

  Widget _buildEditorContent(TrainingPlanState state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Fixed header - not part of scroll view
          Material(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<TrainingPlanCubit>().clearSearch();
                      } else {
                        context.read<TrainingPlanCubit>().searchExercises(
                          value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ModernTextInput(
                    hintText: 'Plan Name',
                    icon: Icons.fitness_center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Plan name is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Training plan name is typically not changed for user plans
                      // But we can keep this for consistency
                    },
                    initialValue:
                        state is TrainingPlanEditing
                            ? state.trainingPlan.name
                            : '',
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                if (state is TrainingPlanSearchingExercises)
                  _buildSearchResults(state)
                else if (state is TrainingPlanEditing)
                  _buildPlanEditor(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(TrainingPlanSearchingExercises state) {
    if (state.exercises.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'No exercises found',
          subtitle: 'Try a different search term',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return ModernSuggestedExerciseCard(
            exercise: state.exercises[index],
            onTap: () {
              _searchController.clear();
              context.read<TrainingPlanCubit>().addExercise(
                _selectedDay,
                state.exercises[index],
              );
            },
          );
        }, childCount: state.exercises.length),
      ),
    );
  }

  Widget _buildPlanEditor(TrainingPlanEditing state) {
    if (state.trainingPlan.days.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.calendar_today,
          title: 'No days yet',
          subtitle: 'Add a day to start building your plan',
        ),
      );
    }

    if (_selectedDay >= state.trainingPlan.days.length) {
      _selectedDay = 0;
    }

    final currentDay = state.trainingPlan.days[_selectedDay];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day selector
          ModernDaySelector(
            selectedDay: _selectedDay,
            days: state.trainingPlan.days,
            onDaySelected: _selectDay,
            onAddDay: () {
              context.read<TrainingPlanCubit>().addDay();
            },
          ),

          const SizedBox(height: 20),

          // Day name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ModernTextInput(
              hintText: 'Day Name',
              icon: Icons.edit_calendar,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Day name is required';
                }
                return null;
              },
              initialValue: currentDay.name ?? 'Day ${_selectedDay + 1}',
              onChanged: (value) {
                context.read<TrainingPlanCubit>().changeDayName(
                  _selectedDay,
                  value,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Exercises list
          if (currentDay.exercises.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'SF-Pro',
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...currentDay.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: ModernExerciseCard(
                  exercise: exercise,
                  cubit: context.read<TrainingPlanCubit>() as dynamic,
                ),
              );
            }),
            const SizedBox(height: 30),
          ],

          // Suggested exercises
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Suggested Exercises',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'SF-Pro',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (currentDay.suggestedExercises.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.sports_gymnastics,
                title: 'No suggestions available',
                subtitle: 'Add exercises to get suggestions',
              ),
            )
          else
            ...currentDay.suggestedExercises
                .take(5)
                .toList()
                .asMap()
                .entries
                .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: ModernSuggestedExerciseCard(
                      exercise: entry.value,
                      onTap: () {
                        _searchController.clear();
                        context.read<TrainingPlanCubit>().addExercise(
                          _selectedDay,
                          entry.value,
                        );
                      },
                    ),
                  );
                }),

          const SizedBox(height: 30),

          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ModernSaveButton(
              label: 'Save Plan',
              onPressed: () {
                // Validate the form before saving
                if (_formKey.currentState!.validate()) {
                  context.read<TrainingPlanCubit>().savePlan(widget.user);
                  context.push(RouteNames.onlineCoaching);
                }
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
