import 'package:dio/src/response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/group%20classes/state.dart';
import 'package:mpc_admin_app/app/models/group_class.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class GroupClassesCubit extends Cubit<GroupClassesState> {
  GroupClassesCubit() : super(GroupClassesInitial());

  Future<void> loadGroupClasses() async {
    emit(GroupClassesLoading());
    try {
      print('Loading group classes...');
      final response = await apiService.get('/group-classes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final classes = data.map((json) => GroupClass.fromJson(json)).toList();

        emit(GroupClassesLoaded(groupClasses: classes));
      } else {
        emit(const GroupClassesError(message: 'Failed to load group classes'));
      }
    } catch (e) {
      emit(GroupClassesError(message: e.toString()));
    }
  }

  void initNewGroupClass() {
    final newClass = GroupClass(
      title: '',
      durationMinutes: 60,
      timeSlots: [],
      date: DateTime.now(),
      spotsAvailable: 10,
      recurring: true,
    );
    emit(GroupClassEditing(groupClass: newClass));
  }

  void initEditGroupClass(GroupClass groupClass) {
    emit(GroupClassEditing(groupClass: groupClass));
  }

  void updateTitle(String title) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(title: title),
        ),
      );
    }
  }

  void updateDuration(int minutes) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(
            durationMinutes: minutes,
          ),
        ),
      );
    }
  }

  void updateDate(DateTime date) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(date: date),
        ),
      );
    }
  }

  void updateSpotsAvailable(int spots) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(
            spotsAvailable: spots,
            timeSlots:
                currentState.groupClass.timeSlots.map((slot) {
                  final updatedSpots =
                      slot.spots.length > spots
                          ? slot.spots.sublist(0, spots)
                          : slot.spots;
                  return TimeSlot(time: slot.time, spots: updatedSpots);
                }).toList(),
          ),
        ),
      );
    }
  }

  void updateRecurring(bool recurring) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(recurring: recurring),
        ),
      );
    }
  }

  void updateDayOfWeek(String dayOfWeek) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(dayOfWeek: dayOfWeek),
        ),
      );
    }
  }

  void addTimeSlot(String time) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      final newSlot = TimeSlot(time: time, spots: []);
      final updatedSlots = [...currentState.groupClass.timeSlots, newSlot];
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(timeSlots: updatedSlots),
        ),
      );
    }
  }

  void removeTimeSlot(int index) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      final updatedSlots = [...currentState.groupClass.timeSlots];
      updatedSlots.removeAt(index);
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(timeSlots: updatedSlots),
        ),
      );
    }
  }

  void removeAttendee(int timeSlotIndex, int spotIndex) {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      final updatedSlots = [...currentState.groupClass.timeSlots];
      final slot = updatedSlots[timeSlotIndex];
      final updatedSpots = [...slot.spots];
      updatedSpots.removeAt(spotIndex);
      updatedSlots[timeSlotIndex] = TimeSlot(
        time: slot.time,
        spots: updatedSpots,
      );
      emit(
        GroupClassEditing(
          groupClass: currentState.groupClass.copyWith(timeSlots: updatedSlots),
        ),
      );
    } else if (currentState is GroupClassViewingAttendees) {
      final updatedSlots = [...currentState.groupClass.timeSlots];
      final slot = updatedSlots[timeSlotIndex];
      final updatedSpots = [...slot.spots];
      updatedSpots.removeAt(spotIndex);
      updatedSlots[timeSlotIndex] = TimeSlot(
        time: slot.time,
        spots: updatedSpots,
      );
      emit(
        GroupClassViewingAttendees(
          groupClass: currentState.groupClass.copyWith(timeSlots: updatedSlots),
        ),
      );
    }
  }

  void viewAttendees(GroupClass groupClass) {
    emit(GroupClassViewingAttendees(groupClass: groupClass));
  }

  void backToEditing() {
    final currentState = state;
    if (currentState is GroupClassViewingAttendees) {
      emit(GroupClassEditing(groupClass: currentState.groupClass));
    }
  }

  Future<void> saveGroupClass() async {
    final currentState = state;
    if (currentState is GroupClassEditing) {
      Response<dynamic> response;
      try {
        emit(GroupClassesLoading());
        if (currentState.groupClass.id == null) {
          response = await apiService.post(
            '/add-group-class',
            currentState.groupClass.toJson(),
          );
        } else {
          response = await apiService.post(
            '/edit-group-class',
            currentState.groupClass.toJson(),
          );
          print(response.data);
        }
        if (response.statusCode == 200) {
          await loadGroupClasses();
        } else {
          emit(const GroupClassesError(message: 'Failed to save group class'));
        }
      } catch (e) {
        emit(GroupClassesError(message: e.toString()));
      }
    }
  }

  Future<void> deleteGroupClass(String id) async {
    try {
      emit(GroupClassesLoading());
      await apiService.post('/delete-group-class', {'id': id});
      await loadGroupClasses();
    } catch (e) {
      emit(GroupClassesError(message: e.toString()));
    }
  }
}
