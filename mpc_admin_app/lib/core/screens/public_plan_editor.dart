import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/cubit.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/state.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/exercise_card.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';

class PublicPlanEditorScreen extends StatefulWidget {
  final PublicPlan? plan;

  const PublicPlanEditorScreen({super.key, this.plan});

  @override
  State<PublicPlanEditorScreen> createState() => _PublicPlanEditorScreenState();
}

class _PublicPlanEditorScreenState extends State<PublicPlanEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _animationController;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plan != null) {
        context.read<PublicPlansCubit>().initEditPlan(widget.plan!);
      } else {
        context.read<PublicPlansCubit>().initNewPlan();
      }
    });
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<PublicPlansCubit, PublicPlansState>(
        builder: (context, state) {
          if (state is PublicPlansError) {
            return _buildErrorState(state);
          } else if (state is PublicPlanEditing ||
              state is PublicPlanSearchingExercises) {
            return _buildEditorContent(state);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildErrorState(PublicPlansError state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
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
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'SF-Pro',
                color: Colors.black,
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
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ModernButton(
              onPressed: () {
                context.read<PublicPlansCubit>().savePublicPlan();
                context.go(RouteNames.trainingPlans);
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
              color: Colors.white,
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

  Widget _buildEditorContent(PublicPlansState state) {
    return CustomScrollView(
      slivers: [
        // Header with search
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<PublicPlansCubit>().clearSearch();
                    } else {
                      context.read<PublicPlansCubit>().searchExercises(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ModernTextInput(
                  hintText: 'Plan Name',
                  icon: Icons.fitness_center,
                  onChanged: (value) {
                    context.read<PublicPlansCubit>().updatePlanName(value);
                  },
                  initialValue: state is PublicPlanEditing
                      ? state.publicPlan.name
                      : '',
                ),
                const SizedBox(height: 12),
                ModernPriceInput(
                  onChanged: (value) {
                    context.read<PublicPlansCubit>().updatePrice(value);
                  },
                  initialValue: state is PublicPlanEditing
                      ? state.publicPlan.price
                      : 0,
                ),
              ],
            ),
          ),
        ),

        // Search results or editor content
        if (state is PublicPlanSearchingExercises)
          _buildSearchResults(state)
        else if (state is PublicPlanEditing)
          _buildPlanEditor(state),
      ],
    );
  }

  Widget _buildSearchResults(PublicPlanSearchingExercises state) {
    if (state.exercises.isEmpty) {
      return SliverFillRemaining(
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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ModernSuggestedExerciseCard(
              exercise: state.exercises[index],
              onTap: () {
                _searchController.clear();
                context.read<PublicPlansCubit>().addExercise(
                      _selectedDay,
                      state.exercises[index],
                    );
              },
            );
          },
          childCount: state.exercises.length,
        ),
      ),
    );
  }

  Widget _buildPlanEditor(PublicPlanEditing state) {
    if (state.publicPlan.days.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.calendar_today,
          title: 'No days yet',
          subtitle: 'Add a day to start building your plan',
        ),
      );
    }

    if (_selectedDay >= state.publicPlan.days.length) {
      _selectedDay = 0;
    }

    final currentDay = state.publicPlan.days[_selectedDay];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day selector
          ModernDaySelector(
            selectedDay: _selectedDay,
            days: state.publicPlan.days,
            onDaySelected: _selectDay,
            onAddDay: () {
              context.read<PublicPlansCubit>().addDay();
            },
          ),

          const SizedBox(height: 20),

          // Day name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ModernTextInput(
              hintText: 'Day Name',
              icon: Icons.edit_calendar,
              initialValue: currentDay.name ?? 'Day ${_selectedDay + 1}',
              onChanged: (value) {
                context.read<PublicPlansCubit>().changeDayName(
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
                  color: Colors.grey[900],
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
                  cubit: context.read<PublicPlansCubit>(),
                ),
              );
            }).toList(),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Suggested Exercises',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'SF-Pro',
                    color: Colors.grey[900],
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
                    context.read<PublicPlansCubit>().addExercise(
                          _selectedDay,
                          entry.value,
                        );
                  },
                ),
              );
            }).toList(),

          const SizedBox(height: 30),

          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ModernSaveButton(
              onPressed: () {
                context.read<PublicPlansCubit>().savePublicPlan();
                context.go(RouteNames.trainingPlans);
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
