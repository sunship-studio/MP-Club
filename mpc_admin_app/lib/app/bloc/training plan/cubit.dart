import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/state.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/models/UserExercise.dart';
import 'package:mpc_admin_app/app/models/TrainingDay.dart';
import 'package:mpc_admin_app/app/models/TrainingPlan.dart';
import 'package:mpc_admin_app/app/models/set.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class TrainingPlanCubit extends Cubit<TrainingPlanState> {
  TrainingPlanCubit() : super(TrainingPlanInitial());
  TrainingPlan trainingPlan = TrainingPlan.empty();
  List<Exercise> exercisesDatabase = [];
  List<Exercise> suggestedExercises = [];

  void updateExerciseSets(String id, int sets) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets;
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

  void updateSetReps(String id, String reps, int index) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(reps: reps);
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

  void changeSetWeight(String id, int weight, int index) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(weight: weight);
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

  void updateSetRIR(String id, int rir, int index) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(rir: rir);
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

  void updateExercise(String id, UserExercise newExercise) {
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
          exercisesDatabase: exercisesDatabase,

          trainingPlan: trainingPlan,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  void addSet(String id) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?.add(ExerciseSet(reps: '8-12', rir: 2, weight: 0));
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

  void deleteLastIndexSet(String id) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          if (day.exercises[i].sets!.isNotEmpty) {
            day.exercises[i].sets!.removeLast();
            emit(
              TrainingPlanEditing(
                trainingPlan: trainingPlan,
                lastUpdated: DateTime.now(),
              ),
            );
          }
          return;
        }
      }
    }
  }

  void addDay() {
    suggestedExercises = [];
    print("Generating suggested exercises for new day");
    for (int i = 0; i < 6; i++) {
      suggestedExercises.add(
        exercisesDatabase[Random().nextInt(exercisesDatabase.length)],
      );
    }
    print("Suggested exercises for new day: $suggestedExercises");
    trainingPlan.days.add(
      TrainingDay(
        exercises: [],
        suggestedExercises: suggestedExercises,
        name: "Day ${trainingPlan.days.length + 1}",
      ),
    );

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

  updateRestTime(String id, int minutes, int seconds) {
    for (var day in trainingPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].minutes = minutes;
          day.exercises[i].seconds = seconds;
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

  void addExercise(int dayIndex, Exercise newExercise) {
    if (trainingPlan.days[dayIndex].exercises.any(
      (exercise) => exercise.id == newExercise.id,
    )) {
      // Exercise already exists in the day's exercises
      return;
    }
    if (dayIndex >= 0 && dayIndex < trainingPlan.days.length) {
      UserExercise exercise = UserExercise(
        name: newExercise.name,
        minutes: 2,
        id: newExercise.id,
        bodyParts: newExercise.bodyParts,
        sets: [
          ExerciseSet(reps: '8-12', rir: 2, weight: 0),
          ExerciseSet(reps: '8-12', rir: 2, weight: 0),
          ExerciseSet(reps: '8-12', rir: 2, weight: 0),
        ],
      );
      trainingPlan.days[dayIndex].exercises.add(exercise);
      // Find 5 new suggested exercises that match the bo dy parts of the added exercise
      trainingPlan.days[dayIndex].suggestedExercises = [];
      for (
        var i = 0;
        i < exercisesDatabase.length &&
            trainingPlan.days[dayIndex].suggestedExercises.length < 5;
        i++
      ) {
        print("Looking for suggested exercise ${i + 1}");
        int randomInt = Random().nextInt(exercisesDatabase.length);
        if (exercisesDatabase[randomInt].bodyParts.any(
              (part) => exercise.bodyParts.contains(part),
            ) &&
            !(trainingPlan.days[dayIndex].exercises.contains(
              exercisesDatabase[randomInt],
            ))) {
          trainingPlan.days[dayIndex].suggestedExercises.add(
            exercisesDatabase[randomInt],
          );
        }
      }
      if (trainingPlan.days[dayIndex].suggestedExercises.length < 5) {
        suggestedExercises = [];
        for (var i = 0; i < 5 && i < exercisesDatabase.length; i++) {
          if (!(trainingPlan.days[dayIndex].exercises.contains(
            exercisesDatabase[i],
          ))) {
            suggestedExercises.add(
              exercisesDatabase[Random().nextInt(exercisesDatabase.length)],
            );
          }
        }
        trainingPlan.days[dayIndex].suggestedExercises = suggestedExercises;
      }
      emit(TrainingPlanInitial());
      emit(
        TrainingPlanEditing(
          trainingPlan: trainingPlan,
          lastUpdated: DateTime.now(),
          exercisesDatabase: exercisesDatabase,
        ),
      );
    }
  }

  Future<void> savePlan(User user) async {
    print('Training Plan: ${this.trainingPlan.toJson()}');
    for (var day in this.trainingPlan.days) {
      for (var exercise in day.exercises) {
        this.trainingPlan.bodyParts!.addAll(exercise.bodyParts);
      }
      this.trainingPlan.bodyParts =
          this.trainingPlan.bodyParts!.toSet().toList();
      final response = await ApiService().post('/save-training-plan', {
        'userId': user.id,
        'trainingPlan': this.trainingPlan.toJson(),
      });

      if (response.statusCode == 200) {
        print('Training plan saved successfully');
      } else {
        print('Failed to save training plan');
        emit(
          TrainingPlanError(
            message: 'Failed to save training plan',
            trainingPlan: this.trainingPlan,
          ),
        );
      }
    }
  }

  // Init
  void init(User user) async {
    this.trainingPlan = user.trainingPlan;
    final response = await apiService.get('/exercises');
    if (response.statusCode == 200) {
      exercisesDatabase =
          (response.data as List)
              .map((exercise) => Exercise.fromJson(exercise))
              .toList();
      print("Fetched ${exercisesDatabase.length} exercises from database");
      if (trainingPlan.days.isEmpty) {
        print("Training plan is empty, adding a new day");
        changeDayName(0, "Plan For ${user.firstName}");
        addDay();

        return;
      } else {
        for (var day in trainingPlan.days) {
          print("Generating suggested exercises for day: ${day.toJson()}");
          if (day.exercises.isEmpty) {
            for (
              var i = 0;
              i < exercisesDatabase.length && day.suggestedExercises.length < 5;
              i++
            ) {
              int randomInt = Random().nextInt(exercisesDatabase.length);

              trainingPlan
                  .days[trainingPlan.days.indexOf(day)]
                  .suggestedExercises
                  .add(exercisesDatabase[randomInt]);
            }
          } else {
            print(
              "Day has exercises, generating suggested exercises based on body parts",
            );
            for (
              var i = 0;
              i < exercisesDatabase.length && day.suggestedExercises.length < 5;
              i++
            ) {
              int randomInt = Random().nextInt(exercisesDatabase.length);
              if (day.exercises.any(
                    (exercise) => exercise.bodyParts.any(
                      (part) =>
                          exercisesDatabase[randomInt].bodyParts.contains(part),
                    ),
                  ) &&
                  !(day.exercises.contains(exercisesDatabase[randomInt]))) {
                print(
                  "Adding suggested exercise: ${exercisesDatabase[randomInt].name}",
                );
                trainingPlan
                    .days[trainingPlan.days.indexOf(day)]
                    .suggestedExercises
                    .add(exercisesDatabase[randomInt]);
              }
            }
          }
        }

        emit(
          TrainingPlanEditing(
            trainingPlan: trainingPlan,
            lastUpdated: DateTime.now(),

            exercisesDatabase: exercisesDatabase,
          ),
        );
      }
    }
  }

  void searchExercises(String query) {
    final results =
        exercisesDatabase
            .where(
              (exercise) =>
                  exercise.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    emit(TrainingPlanSearchingExercises(exercises: results, query: query));
  }

  void clearSearch() {
    emit(
      TrainingPlanEditing(
        trainingPlan: trainingPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  // Add your methods and logic here
}
