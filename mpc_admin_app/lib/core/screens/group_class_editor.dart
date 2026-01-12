import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/group%20classes/cubit.dart';
import 'package:mpc_admin_app/app/bloc/group%20classes/state.dart';
import 'package:mpc_admin_app/app/models/group_class.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';

class GroupClassEditorScreen extends StatefulWidget {
  final GroupClass? groupClass;

  const GroupClassEditorScreen({super.key, this.groupClass});

  @override
  State<GroupClassEditorScreen> createState() => _GroupClassEditorScreenState();
}

class _GroupClassEditorScreenState extends State<GroupClassEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  String _period = 'AM';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.groupClass != null) {
        context.read<GroupClassesCubit>().initEditGroupClass(
          widget.groupClass!,
        );
      } else {
        context.read<GroupClassesCubit>().initNewGroupClass();
      }
    });
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GroupClassesCubit, GroupClassesState>(
        builder: (context, state) {
          if (state is GroupClassesError) {
            return _buildErrorState(state);
          } else if (state is GroupClassEditing) {
            return _buildEditorContent(state);
          } else if (state is GroupClassViewingAttendees) {
            return _buildAttendeesView(state);
          }
          return _buildLoadingState();
        },
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
                context.push(RouteNames.groupClasses);
              },
              label: 'Go Back',
              icon: Icons.arrow_back,
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
            'Loading...',
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

  Widget _buildEditorContent(GroupClassEditing state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Fixed header
          Material(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.groupClass == null
                            ? 'Create Group Class'
                            : 'Edit Group Class',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'SF-Pro',
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ModernTextInput(
                    hintText: 'Class Title',
                    icon: Icons.fitness_center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Class title is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      context.read<GroupClassesCubit>().updateTitle(value);
                    },
                    initialValue: state.groupClass.title,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ModernTextInput(
                          hintText: 'Duration (minutes)',
                          icon: Icons.timer,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Duration is required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isEmpty) return;
                            final duration = int.tryParse(value) ?? 60;
                            context.read<GroupClassesCubit>().updateDuration(
                              duration,
                            );
                          },
                          initialValue:
                              state.groupClass.durationMinutes.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernTextInput(
                          hintText: 'Spots Available',
                          icon: Icons.people,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Spots required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isEmpty) return;
                            final spots = int.tryParse(value) ?? 10;
                            context
                                .read<GroupClassesCubit>()
                                .updateSpotsAvailable(spots);
                          },
                          initialValue:
                              state.groupClass.spotsAvailable.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recurring Checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          color: Theme.of(context).iconTheme.color,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Recurring Class',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'SF-Pro',
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.groupClass.recurring,
                          onChanged: (value) {
                            context.read<GroupClassesCubit>().updateRecurring(
                              value,
                            );
                          },
                          activeThumbColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date Picker (shown when not recurring) or Day of Week Selector (shown when recurring)
                  if (!state.groupClass.recurring)
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.groupClass.date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          context.read<GroupClassesCubit>().updateDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).iconTheme.color,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${state.groupClass.date.day}/${state.groupClass.date.month}/${state.groupClass.date.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'SF-Pro',
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_view_week,
                            color: Theme.of(context).iconTheme.color,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.groupClass.dayOfWeek ?? 'Monday',
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Monday',
                                    child: Text('Monday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Tuesday',
                                    child: Text('Tuesday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Wednesday',
                                    child: Text('Wednesday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Thursday',
                                    child: Text('Thursday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Friday',
                                    child: Text('Friday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Saturday',
                                    child: Text('Saturday'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sunday',
                                    child: Text('Sunday'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    context
                                        .read<GroupClassesCubit>()
                                        .updateDayOfWeek(value);
                                  }
                                },
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Time Slots',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'SF-Pro',
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Add Time Slot Input
                        Row(
                          children: [
                            // Hours TextField
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                controller: _hoursController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: 'HH',
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).cardTheme.color,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    final hour = int.tryParse(value);
                                    if (hour != null &&
                                        (hour < 1 || hour > 12)) {
                                      _hoursController.text = '';
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ':',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'SF-Pro',
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Minutes TextField
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                controller: _minutesController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: 'MM',
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).cardTheme.color,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    final minute = int.tryParse(value);
                                    if (minute != null && minute > 59) {
                                      _minutesController.text = '';
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // AM/PM Selector
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _period = 'AM';
                                      });
                                    },
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _period == 'AM'
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(11),
                                          bottomLeft: Radius.circular(11),
                                        ),
                                      ),
                                      child: Text(
                                        'AM',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SF-Pro',
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _period == 'AM'
                                                  ? Colors.white
                                                  : Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _period = 'PM';
                                      });
                                    },
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _period == 'PM'
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(11),
                                          bottomRight: Radius.circular(11),
                                        ),
                                      ),
                                      child: Text(
                                        'PM',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'SF-Pro',
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _period == 'PM'
                                                  ? Colors.white
                                                  : Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Add Button
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_hoursController.text.isNotEmpty &&
                                    _minutesController.text.isNotEmpty) {
                                  final hour = _hoursController.text.padLeft(
                                    2,
                                    '0',
                                  );
                                  final minute = _minutesController.text
                                      .padLeft(2, '0');
                                  final timeString = '$hour:$minute $_period';
                                  context.read<GroupClassesCubit>().addTimeSlot(
                                    timeString,
                                  );
                                  _hoursController.clear();
                                  _minutesController.clear();
                                  setState(() {
                                    _period = 'AM';
                                  });
                                }
                              },

                              label: const Icon(Icons.add, size: 20),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Time Slots List
                        ...state.groupClass.timeSlots.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final slot = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TimeSlotCard(
                              timeSlot: slot,
                              onRemove: () {
                                context
                                    .read<GroupClassesCubit>()
                                    .removeTimeSlot(index);
                              },
                              onRemoveAttendee: (spotIndex) {
                                context
                                    .read<GroupClassesCubit>()
                                    .removeAttendee(index, spotIndex);
                              },
                              maxSpots: state.groupClass.spotsAvailable,
                            ),
                          );
                        }),

                        const SizedBox(height: 30),

                        // Save button
                        ModernSaveButton(
                          label: 'Save Class',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<GroupClassesCubit>()
                                  .saveGroupClass();
                              context.push(RouteNames.groupClasses);
                            }
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesView(GroupClassViewingAttendees state) {
    return Column(
      children: [
        Material(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.read<GroupClassesCubit>().backToEditing();
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Class Attendees',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'SF-Pro',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.groupClass.timeSlots.length,
            itemBuilder: (context, index) {
              final slot = state.groupClass.timeSlots[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TimeSlotCard(
                  timeSlot: slot,
                  onRemove: null,
                  onRemoveAttendee: (spotIndex) {
                    context.read<GroupClassesCubit>().removeAttendee(
                      index,
                      spotIndex,
                    );
                  },
                  maxSpots: state.groupClass.spotsAvailable,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TimeSlotCard extends StatelessWidget {
  final TimeSlot timeSlot;
  final VoidCallback? onRemove;
  final Function(int) onRemoveAttendee;
  final int maxSpots;

  const TimeSlotCard({
    super.key,
    required this.timeSlot,
    this.onRemove,
    required this.onRemoveAttendee,
    required this.maxSpots,
  });

  @override
  Widget build(BuildContext context) {
    final bookedSpots = timeSlot.spots.length;
    final availableSpots = maxSpots - bookedSpots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeSlot.time,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'SF-Pro',
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bookedSpots/$maxSpots spots booked',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'SF-Pro',
                        color:
                            bookedSpots >= maxSpots
                                ? Colors.red
                                : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onRemove,
                ),
            ],
          ),
          if (timeSlot.spots.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...timeSlot.spots.asMap().entries.map((entry) {
              final index = entry.key;
              final spot = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${spot.firstName} ${spot.lastName}',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'SF-Pro',
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            spot.email,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'SF-Pro',
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red[400],
                        size: 20,
                      ),
                      onPressed: () => onRemoveAttendee(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
