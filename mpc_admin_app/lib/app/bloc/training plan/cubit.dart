import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/state.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/TrainingDay.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';

class TrainingPlanCubit extends Cubit<TrainingPlanState> {
  TrainingPlanCubit({required this.trainingPlan})
    : super(
        TrainingPlanEditing(
          trainingPlan: trainingPlan,
          lastUpdated: DateTime.now(),
        ),
      );
  TrainingPlan trainingPlan;

  void saveTrainingPlan(TrainingPlan trainingPlan) {
    this.trainingPlan = trainingPlan;
    emit(
      TrainingPlanEditing(
        trainingPlan: trainingPlan,
        lastUpdated: DateTime.now(),
      ),
    );

    // api call to save training plan
  }

  void updateExercise(String id, Exercise newExercise) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i] = newExercise;
          emit(
            TrainingPlanEditing(
              trainingPlan: trainingPlan,
              lastUpdated: DateTime.now(),
            ),
          );
          return;
        }
      }
    }
  }

  void changeDayName(int index, String newName) {
    if (index >= 0 && index < trainingPlan.days.length) {
      trainingPlan.days[index].name = newName;
      emit(
        TrainingPlanEditing(
          trainingPlan: trainingPlan,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  void addDay() {
    trainingPlan.days.add(TrainingDay(exercises: []));
    emit(
      TrainingPlanEditing(
        trainingPlan: trainingPlan,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void deleteExercise(String id) {
    for (var day in trainingPlan.days) {
      day.exercises.removeWhere((exercise) => exercise.id == id);
    }
    emit(
      TrainingPlanEditing(
        trainingPlan: trainingPlan,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void addExercise(String dayName, Exercise newExercise) {
    for (var day in trainingPlan.days) {
      if (day.name == dayName) {
        day.exercises.add(newExercise);
        emit(
          TrainingPlanEditing(
            trainingPlan: trainingPlan,
            lastUpdated: DateTime.now(),
          ),
        );
        return;
      }
    }
  }

  // Init
  void init() {
    if (trainingPlan.days.isEmpty) {
      addDay();
    }
  }

  // Add your methods and logic here
}
