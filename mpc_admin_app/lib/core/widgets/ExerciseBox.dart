import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/models/UserExercise.dart';
import 'package:mpc_admin_app/core/theme/design_system.dart';

class ExerciseBox extends StatefulWidget {
  ExerciseBox({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onWeightChange,
    required this.onRepsChange,
    required this.onRestTimeChange,
    required this.onRIRChange,
  });
  UserExercise exercise;
  Function onDelete;
  Function onAddSet;
  Function onRemoveSet;
  Function onWeightChange;
  Function onRepsChange;
  Function onRIRChange;
  Function onRestTimeChange;

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
      margin: const EdgeInsets.only(bottom: kSpacingMedium),
      padding: const EdgeInsets.symmetric(
        vertical: kSpacingMedium,
        horizontal: kSpacingLarge,
      ),
      decoration: BoxDecoration(
        color: kBackgroundWhite,
        borderRadius: kBorderRadiusCardAll,
        boxShadow: kShadowMedium(context),
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
              onTap: expandWidget,
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
                    const SizedBox(width: kSpacingMedium),
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
                        const SizedBox(height: kSpacingSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            NumberInput(
                              value: widget.exercise.sets!.length,
                              label: "Sets",

                              initialValue: widget.exercise.sets!.length,
                              onChanged: (value) {
                                if (value > widget.exercise.sets!.length) {
                                  widget.onAddSet();
                                } else if (value <
                                    widget.exercise.sets!.length) {
                                  widget.onRemoveSet();
                                }
                              },
                            ),
                            const SizedBox(width: kSpacingMedium),
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
                                const SizedBox(height: kSpacingXSmall),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: kBorderRadiusMediumAll,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
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
                                      SizedBox(
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
                                            widget.onRestTimeChange(
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
                              widget.onDelete();
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
                          const SizedBox(height: kSpacingXXLarge),
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
                            borderRadius: kBorderRadiusMediumAll,
                          ),
                          margin: EdgeInsets.only(bottom: 10),

                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,

                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: kBorderRadiusMediumAll,
                                ),
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
                              ),
                              const SizedBox(width: kSpacingMedium),
                              NumberInput(
                                value: widget.exercise.sets![i].reps,
                                label: "Reps",
                                initialValue: widget.exercise.sets![i].reps,
                                onChanged: (value) {
                                  widget.onRepsChange(value, i);
                                },
                              ),
                              const SizedBox(width: kSpacingMedium),
                              NumberInput(
                                value: widget.exercise.sets![i].rir,
                                label: "RiR",
                                initialValue: widget.exercise.sets![i].rir,
                                onChanged: (value) {
                                  widget.onRIRChange(value, i);
                                },
                              ),
                              const SizedBox(width: kSpacingMedium),
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
                                  const SizedBox(height: kSpacingXSmall),
                                  Container(
                                    width: 70,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: kBorderRadiusMediumAll,
                                    ),
                                    child: TextField(
                                      onChanged: (value) {
                                        double weight =
                                            double.tryParse(value) ?? 0;
                                        widget.onWeightChange(weight, i);
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
    this.value = 0,
    this.onChanged,
  });

  String label;
  Function? onChanged;
  int initialValue;
  int value = 0;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  @override
  void initState() {
    widget.value = widget.initialValue;
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
        const SizedBox(height: kSpacingXSmall),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: kBorderRadiusMediumAll,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.value > 1) {
                    widget.value = widget.value - 1;
                    setState(() {});
                    if (widget.onChanged != null) {
                      widget.onChanged!(widget.value);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 77, 77, 77),
                    borderRadius: kBorderRadiusMediumAll,
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: kSpacingMedium),
              Text(
                "${widget.value}",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: kSpacingMedium),
              GestureDetector(
                onTap: () {
                  widget.value = widget.value + 1;
                  setState(() {});
                  if (widget.onChanged != null) {
                    widget.onChanged!(widget.value);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 77, 77, 77),
                    borderRadius: kBorderRadiusMediumAll,
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
