import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/TrainingDay.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';

class LogWorkoutResult {
  final TrainingDay day;
  final DateTime date;

  LogWorkoutResult({required this.day, required this.date});
}

class LogWorkoutScreen extends StatefulWidget {
  final TrainingDay trainingDay;

  const LogWorkoutScreen({super.key, required this.trainingDay});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  late TrainingDay _day;
  late DateTime _selectedDate;

  // Per-set controllers: outer list = exercises, inner list = sets
  late List<List<TextEditingController>> _repsControllers;
  late List<List<TextEditingController>> _weightControllers;

  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _day = widget.trainingDay.deepCopy();
    _selectedDate = DateTime.now();

    _repsControllers = _day.exercises.map((ex) {
      return (ex.sets ?? []).map((s) {
        return TextEditingController(
          text: s.actualReps?.toString() ?? '',
        );
      }).toList();
    }).toList();

    _weightControllers = _day.exercises.map((ex) {
      return (ex.sets ?? []).map((s) {
        return TextEditingController(text: s.weight.toString());
      }).toList();
    }).toList();
  }

  @override
  void dispose() {
    for (final list in _repsControllers) {
      for (final c in list) {
        c.dispose();
      }
    }
    for (final list in _weightControllers) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() {
        _dirty = true;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime tempDate = _selectedDate;
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280.h,
          color: AppColors.lightScaffoldColor,
          child: Column(
            children: [
              Container(
                color: AppColors.lightScaffoldColor2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.greyTextColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempDate;
                          _markDirty();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime.now().subtract(
                    const Duration(days: 365),
                  ),
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved entries. Going back will discard them.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    // Apply controller values into the model.
    for (int e = 0; e < _day.exercises.length; e++) {
      final sets = _day.exercises[e].sets ?? [];
      for (int s = 0; s < sets.length; s++) {
        final repsText = _repsControllers[e][s].text.trim();
        final weightText = _weightControllers[e][s].text.trim();

        final actual = repsText.isEmpty ? null : int.tryParse(repsText);
        final weight = int.tryParse(weightText) ?? sets[s].weight;

        sets[s] = sets[s].copyWith(
          actualReps: actual,
          weight: weight,
        );
      }
      _day.exercises[e].sets = sets;
    }

    Navigator.of(context).pop(
      LogWorkoutResult(day: _day, date: _selectedDate),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
    if (isYesterday) return 'Yesterday';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscard();
        if (ok && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
        backgroundColor: AppColors.lightScaffoldColor,
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
            margin: EdgeInsets.only(bottom: 48.h),
            child: CircularButton(
              borderColor: Colors.grey[800],
              label: 'Save Workout',
              dark: true,
              color: AppColors.darkScaffoldColor,
              onTap: _save,
            ),
          ),
        ),
        body: Column(
          children: [
            MpcHeader(
              label: 'LOG WORKOUT',
              backgroundColor: AppColors.lightScaffoldColor,
              textColor: AppColors.darkTextColor,
              onBack: () async {
                final ok = await _confirmDiscard();
                if (ok && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding.w,
                  vertical: 12.h,
                ),
                children: [
                  Text(
                    _day.name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                  Gap(8.h),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightCardColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 18.sp,
                            color: AppColors.textSubColor,
                          ),
                          Gap(8.w),
                          Text(
                            _formatDate(_selectedDate),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.darkTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.blueColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          size: 18.sp,
                          color: AppColors.blueColor,
                        ),
                        Gap(8.w),
                        Expanded(
                          child: Text(
                            'Only mark the sets where you didn\'t hit the target. Sets left blank will count as Met Target.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.darkTextColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  ..._day.exercises.asMap().entries.map((entry) {
                    final exIndex = entry.key;
                    final exercise = entry.value;
                    final sets = exercise.sets ?? [];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.lightCardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextColor,
                            ),
                          ),
                          Gap(10.h),
                          // Header row
                          Row(
                            children: [
                              SizedBox(
                                width: 28.w,
                                child: Text(
                                  '#',
                                  style: _headerStyle(),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Target',
                                  style: _headerStyle(),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Actual reps',
                                  style: _headerStyle(),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Weight (kg)',
                                  style: _headerStyle(),
                                ),
                              ),
                              SizedBox(
                                width: 40.w,
                                child: Text(
                                  'RIR',
                                  style: _headerStyle(),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: AppColors.dividerColor, height: 18.h),
                          ...sets.asMap().entries.map((setEntry) {
                            final setIndex = setEntry.key;
                            final set = setEntry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 28.w,
                                    child: Text(
                                      '${setIndex + 1}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkTextColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      set.reps,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.darkTextColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: CupertinoTextField(
                                        controller: _repsControllers[exIndex]
                                            [setIndex],
                                        keyboardType: TextInputType.number,
                                        placeholder: 'Met',
                                        placeholderStyle: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.greyTextColor,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.darkTextColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightScaffoldColor2,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        onChanged: (_) => _markDirty(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: CupertinoTextField(
                                        controller: _weightControllers[exIndex]
                                            [setIndex],
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.darkTextColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightScaffoldColor2,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        onChanged: (_) => _markDirty(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40.w,
                                    child: Text(
                                      '${set.rir}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.textSubColor,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                  Gap(40.h),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.greyTextColor,
        letterSpacing: 0.4,
      );
}
