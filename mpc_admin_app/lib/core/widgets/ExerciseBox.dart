import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/UserExercise.dart';

class ExerciseBox extends StatefulWidget {
  ExerciseBox({super.key, required this.exercise});
  UserExercise exercise;

  @override
  State<ExerciseBox> createState() => _ExerciseBoxState();
}

class _ExerciseBoxState extends State<ExerciseBox> {
  TextEditingController restMinController = TextEditingController(text: "2");
  TextEditingController restSecController = TextEditingController();
  bool isExapnded = false;

  void expandWidget() {
    setState(() {
      isExapnded = !isExapnded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onLongPress: expandWidget,
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   child: Image.asset(
                    //     'assets/squat.png',
                    //     width: MediaQuery.of(context).size.width * 0.2,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            widget.exercise.name,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'SF-Pro',
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            NumberInput(
                              label: "Sets",
                              initialValue: widget.exercise.sets!.length,
                              onChanged: (value) {
                                if (value > widget.exercise.sets!.length) {
                                  context.read<TrainingPlanCubit>().addSet(
                                    widget.exercise.id!,
                                  );
                                } else if (value <
                                    widget.exercise.sets!.length) {
                                  context
                                      .read<TrainingPlanCubit>()
                                      .deleteLastIndexSet(widget.exercise.id!);
                                }
                              },
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rest Time",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'SF-Pro',
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 50,

                                        child: TextField(
                                          controller: restMinController,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 5,
                                                  horizontal: 10,
                                                ),
                                            hintText: "mins",
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'SF-Pro',
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'SF-Pro',
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 10,
                                        width: 1,
                                        color: Colors.grey[400],
                                      ),
                                      Container(
                                        width: 50,

                                        child: TextField(
                                          controller: restSecController,
                                          onChanged: (value) {
                                            int minutes =
                                                int.tryParse(
                                                  restMinController.text,
                                                ) ??
                                                0;
                                            int seconds =
                                                int.tryParse(value) ?? 0;
                                            context
                                                .read<TrainingPlanCubit>()
                                                .updateRestTime(
                                                  widget.exercise.id!,
                                                  minutes,
                                                  seconds,
                                                );
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 5,
                                                  horizontal: 10,
                                                ),
                                            hintText: "secs",
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'SF-Pro',
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'SF-Pro',
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<TrainingPlanCubit>().deleteExercise(
                                widget.exercise.id!,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red[900],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Icon(
                            isExapnded
                                ? Coolicons.chevron_down
                                : Coolicons.chevron_right,
                            size: 24,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExapnded)
            Column(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 15,
                    right: 15,
                    bottom: 0,
                  ),
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: EdgeInsets.only(bottom: 10),

                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: Text(
                                    "${i + 1}",
                                    style: TextStyle(
                                      fontFamily: 'SF-Pro',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              SizedBox(width: 12),
                              NumberInput(
                                label: "Reps",
                                initialValue: widget.exercise.sets![i].reps,
                                onChanged: (value) {
                                  context
                                      .read<TrainingPlanCubit>()
                                      .updateSetReps(
                                        widget.exercise.id!,
                                        value,
                                        i,
                                      );
                                },
                              ),
                              SizedBox(width: 10),
                              NumberInput(
                                label: "RiR",
                                initialValue: widget.exercise.sets![i].rir,
                                onChanged: (value) {
                                  context
                                      .read<TrainingPlanCubit>()
                                      .updateSetRIR(
                                        widget.exercise.id!,
                                        value,
                                        i,
                                      );
                                },
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Weight",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'SF-Pro',
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width: 70,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      onChanged: (value) {
                                        context
                                            .read<TrainingPlanCubit>()
                                            .changeSetWeight(
                                              widget.exercise.id!,
                                              int.tryParse(value) ?? 0,
                                              i,
                                            );
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 0,
                                        ),
                                        hintText: "kg",
                                        hintStyle: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'SF-Pro',
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'SF-Pro',
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: widget.exercise.sets!.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class NumberInput extends StatefulWidget {
  NumberInput({
    super.key,
    this.label = "Sets",
    this.initialValue = 2,
    this.onChanged,
  });

  String label;
  Function? onChanged;
  int initialValue;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  int value = 0;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'SF-Pro',
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 1) {
                    value = value - 1;
                    setState(() {});
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 77, 77, 77),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "${value}",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  value = value + 1;
                  setState(() {});
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 77, 77, 77),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
