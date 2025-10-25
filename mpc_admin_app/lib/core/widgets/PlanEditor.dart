import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/state.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/ExerciseBox.dart';
import 'package:mpc_admin_app/core/widgets/SuggestedExercise.dart';

TextEditingController _searchController = TextEditingController();

class PlanEditor extends StatefulWidget {
  const PlanEditor({super.key, required this.user});
  final User user;

  @override
  State<PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<PlanEditor> {
  final bool _nameOfPlanIsEmpty = true;

  int selectedDay = 0;
  void selectDay(int index) {
    setState(() {
      selectedDay = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingPlanCubit, TrainingPlanState>(
      builder: (context, state) {
        if (state is TrainingPlanError) {
          return Center(
            child: Column(
              children: [
                Text(
                  "Error: ${state.message}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'SF-Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    context.read<TrainingPlanCubit>().savePlan(widget.user);
                    context.go(RouteNames.onlineCoaching);
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        } else if (state is TrainingPlanEditing ||
            state is TrainingPlanSearchingExercises) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExercisesSearchBar(),
                SizedBox(height: 12),
                TrainingPlanNameInput(),
                SizedBox(height: 12),
                state is TrainingPlanSearchingExercises &&
                        state.exercises.isNotEmpty
                    ? Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(),
                        itemBuilder:
                            (context, index) => SuggestedExerciseBox(
                              searchController: _searchController,
                              selectedDayIndex: selectedDay,
                              exercise: state.exercises[index],
                            ),
                        itemCount: state.exercises.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    )
                    : state is TrainingPlanSearchingExercises &&
                        state.exercises.isEmpty
                    ? Expanded(
                      child: Center(
                        child: Text(
                          "No exercises found",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'SF-Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    : state is TrainingPlanEditing
                    ? Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DaySelector(
                              selectedDay: selectedDay,
                              days: state.trainingPlan.days,
                              selectDay: selectDay,
                            ),
                            SizedBox(height: 12),
                            DayNameInput(
                              selectedDay: selectedDay,
                              trainingPlan: state.trainingPlan,
                            ),
                            // Exercise List
                            state.trainingPlan.days.isEmpty ||
                                    state
                                        .trainingPlan
                                        .days[selectedDay]
                                        .exercises
                                        .isEmpty
                                ? Container()
                                : ListView.builder(
                                  padding: EdgeInsets.only(),
                                  itemBuilder:
                                      (context, index) => ExerciseBox(
                                        exercise:
                                            state
                                                .trainingPlan
                                                .days[selectedDay]
                                                .exercises[index],
                                      ),
                                  itemCount:
                                      state
                                          .trainingPlan
                                          .days[selectedDay]
                                          .exercises
                                          .length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                ),

                            Text(
                              "Suggested",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'SF-Pro',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 12),
                            state
                                    .trainingPlan
                                    .days[selectedDay]
                                    .suggestedExercises
                                    .isEmpty
                                ? Container()
                                : ListView.builder(
                                  padding: EdgeInsets.only(),
                                  itemBuilder:
                                      (context, index) => SuggestedExerciseBox(
                                        searchController: _searchController,
                                        selectedDayIndex: selectedDay,
                                        exercise:
                                            state
                                                .trainingPlan
                                                .days[selectedDay]
                                                .suggestedExercises[index],
                                      ),
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                ),
                            const SizedBox(height: 20),
                            SaveButton(user: widget.user),
                          ],
                        ),
                      ),
                    )
                    : Container(),
              ],
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 19, 157, 221),
            strokeWidth: 2,
          ),
        );
      },
    );
  }
}

class TrainingPlanNameInput extends StatefulWidget {
  const TrainingPlanNameInput({super.key});

  @override
  State<TrainingPlanNameInput> createState() => _TrainingPlanNameInputState();
}

class _TrainingPlanNameInputState extends State<TrainingPlanNameInput> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (context.read<TrainingPlanCubit>().state is TrainingPlanEditing) {
      _nameController.text =
          (context.read<TrainingPlanCubit>().state as TrainingPlanEditing)
              .trainingPlan
              .name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: _nameController,

        onChanged: (value) {},
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: 'name of the plan',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'SF-Pro',
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  const SaveButton({super.key, required this.user});

  final User user;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {
        print(
          (context.read<TrainingPlanCubit>().state as TrainingPlanEditing)
              .trainingPlan
              .toJson(),
        );

        context.read<TrainingPlanCubit>().savePlan(widget.user);
        context.go(RouteNames.onlineCoaching);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              "Save Plan",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'SF-Pro',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExercisesSearchBar extends StatelessWidget {
  const ExercisesSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<TrainingPlanCubit>().clearSearch();
          } else {
            context.read<TrainingPlanCubit>().searchExercises(value);
          }
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search, color: Colors.grey[900], size: 32),
          border: InputBorder.none,
          hintText: 'Search exercises',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'SF-Pro',
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class DayNameInput extends StatefulWidget {
  DayNameInput({
    super.key,
    required this.selectedDay,
    required this.trainingPlan,
  });
  int selectedDay;
  TrainingPlan trainingPlan;

  @override
  State<DayNameInput> createState() => _DayNameInputState();
}

class _DayNameInputState extends State<DayNameInput> {
  final TextEditingController _dayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _dayNameController.text =
        widget.trainingPlan.days[widget.selectedDay].name ??
        'Day ${widget.selectedDay + 1}';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: _dayNameController,
        onChanged: (value) {
          context.read<TrainingPlanCubit>().changeDayName(
            widget.selectedDay,
            value,
          );
        },

        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,

          hintText: 'name of the day',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'SF-Pro',
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class DaySelector extends StatelessWidget {
  DaySelector({
    super.key,
    required this.selectedDay,
    required this.days,
    required this.selectDay,
  });

  int selectedDay;
  List days;
  Function(int) selectDay;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children:
                  days
                      .asMap()
                      .entries
                      .map(
                        (entry) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              selectDay(entry.key);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right:
                                      entry.key != days.length - 1
                                          ? BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          )
                                          : BorderSide.none,
                                ),
                                borderRadius:
                                    entry.key == 0
                                        ? BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        )
                                        : BorderRadius.circular(0),
                                color:
                                    selectedDay == entry.key
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Day ${entry.key + 1}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SF-Pro',
                                  color:
                                      selectedDay == entry.key
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("Add Day");
              context.read<TrainingPlanCubit>().addDay();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white, width: 2)),
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
