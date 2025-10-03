import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/state.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/core/widgets/ExerciseBox.dart';
import 'package:mpc_admin_app/core/widgets/SuggestedExercise.dart';

class PlanEditor extends StatefulWidget {
  PlanEditor({super.key, required this.user});
  User user;

  @override
  State<PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<PlanEditor> {
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
        if (state is TrainingPlanEditing) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExercisesSearchBar(),
                DaySelector(
                  selectedDay: selectedDay,
                  days: state.trainingPlan.days,
                  selectDay: selectDay,
                ),
                DayNameInput(
                  selectedDay: selectedDay,
                  trainingPlan: state.trainingPlan,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise List
                        state.trainingPlan.days[selectedDay].exercises.isEmpty
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
                        ListView.builder(
                          padding: EdgeInsets.only(),
                          itemBuilder:
                              (context, index) => SuggestedExerciseBox(),
                          itemCount: 5,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                      ],
                    ),
                  ),
                ),
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
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey[900], size: 32),
          border: InputBorder.none,
          hintText: 'Search exercises',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'SF-Pro',
            color: Colors.grey[400],
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
  TextEditingController dayNameController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    dayNameController.text = widget.trainingPlan.days[widget.selectedDay].name;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: dayNameController,
        onChanged: (value) {
          context.read<TrainingPlanCubit>().changeDayName(
            widget.selectedDay,
            value,
          );
        },
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: 'name of the day',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'SF-Pro',
            color: Colors.grey[400],
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
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
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
                                "Day " + (entry.key + 1).toString(),
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
