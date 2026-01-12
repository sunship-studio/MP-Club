import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/models/UserExercise.dart';

class ModernExerciseCard extends StatefulWidget {
  final UserExercise exercise;
  var cubit;

  ModernExerciseCard({super.key, required this.exercise, required this.cubit});

  @override
  State<ModernExerciseCard> createState() => _ModernExerciseCardState();
}

class _ModernExerciseCardState extends State<ModernExerciseCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late TextEditingController _restMinController;
  late TextEditingController _restSecController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _restMinController = TextEditingController(
      text: (widget.exercise.minutes ?? 0).toString(),
    );
    _restSecController = TextEditingController(
      text: (widget.exercise.seconds ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _restMinController.dispose();
    _restSecController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.08,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Exercise icon
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
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Exercise details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'SF-Pro',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.repeat,
                              label:
                                  '${widget.exercise.sets?.length ?? 0} sets',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label:
                                  '${widget.exercise.minutes ?? 0}:${(widget.exercise.seconds ?? 0).toString().padLeft(2, '0')}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete and expand buttons
                  Column(
                    children: [
                      _ActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        onTap: () {
                          widget.cubit.deleteExercise(widget.exercise.id!);
                        },
                      ),
                      const SizedBox(height: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rest time inputs
                      Row(
                        children: [
                          Expanded(
                            child: _RestTimeInput(
                              controller: _restMinController,
                              label: 'Minutes',
                              onChanged: (value) {
                                final minutes = int.tryParse(value) ?? 0;
                                final seconds =
                                    int.tryParse(_restSecController.text) ?? 0;
                                widget.cubit.updateRestTime(
                                  widget.exercise.id!,
                                  minutes,
                                  seconds,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RestTimeInput(
                              controller: _restSecController,
                              label: 'Seconds',
                              onChanged: (value) {
                                final minutes =
                                    int.tryParse(_restMinController.text) ?? 0;
                                final seconds = int.tryParse(value) ?? 0;
                                widget.cubit.updateRestTime(
                                  widget.exercise.id!,
                                  minutes,
                                  seconds,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sets count adjuster
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sets',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'SF-Pro',
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _NumberAdjuster(
                            value: widget.exercise.sets?.length ?? 0,
                            onIncrement: () {
                              widget.cubit.addSet(widget.exercise.id!);
                            },
                            onDecrement: () {
                              widget.cubit.deleteLastIndexSet(
                                widget.exercise.id!,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sets list
                      if (widget.exercise.sets != null &&
                          widget.exercise.sets!.isNotEmpty)
                        Column(
                          children:
                              widget.exercise.sets!.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final set = entry.value;
                                return _SetRow(
                                  setNumber: index + 1,
                                  reps: set.reps,
                                  rir: set.rir,
                                  weight: set.weight,
                                  onRepsChanged: (value) {
                                    widget.cubit.updateSetReps(
                                      widget.exercise.id!,
                                      value,
                                      index,
                                    );
                                  },
                                  onRirChanged: (value) {
                                    widget.cubit.updateSetRIR(
                                      widget.exercise.id!,
                                      value,
                                      index,
                                    );
                                  },
                                  onWeightChanged: (value) {
                                    widget.cubit.changeSetWeight(
                                      widget.exercise.id!,
                                      value,
                                      index,
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'SF-Pro',
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// Rest time input widget
class _RestTimeInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(String) onChanged;

  const _RestTimeInput({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'SF-Pro',
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'SF-Pro',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            fillColor: Theme.of(context).cardTheme.color!,
            filled: true,
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: '0',
            hintStyle: TextStyle(
              fontSize: 16,
              fontFamily: 'SF-Pro',
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// Number adjuster widget
class _NumberAdjuster extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _NumberAdjuster({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _AdjusterButton(
            icon: Icons.remove,
            onTap: value > 1 ? onDecrement : null,
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          _AdjusterButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _AdjusterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _AdjusterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[800])
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              onTap != null
                  ? Colors.white
                  : Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

// Set row widget
class _SetRow extends StatelessWidget {
  final int setNumber;
  final int reps;
  final int rir;
  final int weight;
  final Function(int) onRepsChanged;
  final Function(int) onRirChanged;
  final Function(int) onWeightChanged;

  const _SetRow({
    required this.setNumber,
    required this.reps,
    required this.rir,
    required this.weight,
    required this.onRepsChanged,
    required this.onRirChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Set number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: const TextStyle(
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps
          Expanded(
            child: _SetInput(
              label: 'Reps',
              value: reps,
              onChanged: onRepsChanged,
            ),
          ),
          const SizedBox(width: 8),

          // RIR
          Expanded(
            child: _SetInput(label: 'RiR', value: rir, onChanged: onRirChanged),
          ),
          const SizedBox(width: 8),

          // Weight
          Expanded(
            child: _WeightInput(value: weight, onChanged: onWeightChanged),
          ),
        ],
      ),
    );
  }
}

// Set input widget
class _SetInput extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const _SetInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'SF-Pro',
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value.toString()),
          onChanged: (val) {
            final intVal = int.tryParse(val) ?? 0;
            onChanged(intVal);
          },
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'SF-Pro',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      ],
    );
  }
}

// Weight input widget
class _WeightInput extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const _WeightInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight',
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'SF-Pro',
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(
            text: value > 0 ? value.toString() : '',
          ),
          onChanged: (val) {
            final intVal = int.tryParse(val) ?? 0;
            onChanged(intVal);
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'SF-Pro',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            hintText: 'kg',
            hintStyle: TextStyle(
              fontSize: 11,
              fontFamily: 'SF-Pro',
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
