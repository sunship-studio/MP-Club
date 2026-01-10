import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/state.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/app/models/TrainingDay.dart';
import 'package:mpc_admin_app/app/models/UserExercise.dart';
import 'package:mpc_admin_app/app/models/set.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class PublicPlansCubit extends Cubit<PublicPlansState> {
  PublicPlansCubit() : super(PublicPlansInitial());
  PublicPlan publicPlan = PublicPlan(name: '', price: 0);
  List<Exercise> exercisesDatabase = [];
  List<Exercise> suggestedExercises = [];

  Future<void> loadPlans() async {
    emit(PublicPlansLoading());

    final response = await apiService.get('/training-plans');
    print('Response data: ${response.data}');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      final plans = data.map((json) => PublicPlan.fromJson(json)).toList().reversed.toList();

      emit(PublicPlansLoaded(plans: plans));
    } else {
      emit(PublicPlansError(message: 'Failed to load plans'));
    }
  }

  Future<void> createPlan(PublicPlan plan, String filePath) async {
    emit(PublicPlansLoading());
    try {
      final uploadUrl = await uploadExcelFile(filePath);
      if (uploadUrl == null) {
        emit(PublicPlansError(message: 'Failed to upload Excel file'));
        return;
      }
      plan.excelFileUrl = uploadUrl;
      print(uploadUrl);
      print(plan.toJson());
      final response = await apiService.post(
        '/add-training-plan',
        plan.toJson(),
      );
      print('Create plan response status: ${response.statusCode}');
      print('Create plan response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to create plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<void> updatePlan(String planId, PublicPlan plan) async {
    emit(PublicPlansLoading());
    try {
      final response = await apiService.post('/edit-training-plan', {
        ...plan.toJson(),
        'id': planId,
      });

      if (response.statusCode == 200) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to update plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<void> deletePlan(String planId) async {
    emit(PublicPlansLoading());
    try {
      final response = await apiService.post('/delete-training-plan', {
        'id': planId,
      });

      if (response.statusCode == 200) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to delete plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<String?> uploadExcelFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await apiService.postFormData(
        endpoint: '/upload-training-plan-file',
        formData: formData,
      );

      if (response.statusCode == 200) {
        return response.data['url'] as String;
      }
      return null;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Editing methods for PublicPlanEditor
  void initNewPlan() async {
    publicPlan = PublicPlan(
      name: 'New Public Plan',
      excelFileUrl: '',

      price: 0,
    );

    final response = await apiService.get('/exercises');
    if (response.statusCode == 200) {
      exercisesDatabase =
          (response.data as List)
              .map((exercise) => Exercise.fromJson(exercise))
              .toList();
      addDay();
    }
  }

  void initEditPlan(PublicPlan plan) async {
    publicPlan = plan;

    final response = await apiService.get('/exercises');
    if (response.statusCode == 200) {
      exercisesDatabase =
          (response.data as List)
              .map((exercise) => Exercise.fromJson(exercise))
              .toList();

      // Generate suggested exercises for each day
      for (var day in publicPlan.days) {
        if (day.suggestedExercises.isEmpty) {
          day.suggestedExercises = [];
          for (
            var i = 0;
            i < exercisesDatabase.length && day.suggestedExercises.length < 5;
            i++
          ) {
            int randomInt = Random().nextInt(exercisesDatabase.length);
            if (!day.exercises.any(
              (ex) => ex.id == exercisesDatabase[randomInt].id,
            )) {
              day.suggestedExercises.add(exercisesDatabase[randomInt]);
            }
          }
        }
      }

      emit(
        PublicPlanEditing(
          publicPlan: publicPlan,
          lastUpdated: DateTime.now(),
          exercisesDatabase: exercisesDatabase,
        ),
      );
    }
  }

  void updatePlanName(String name) {
    publicPlan.name = name;
    emit(
      PublicPlanEditing(
        publicPlan: publicPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  void updatePrice(double price) {
    publicPlan.price = price;
    emit(
      PublicPlanEditing(
        publicPlan: publicPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  void addDay() {
    suggestedExercises = [];
    for (int i = 0; i < 6; i++) {
      suggestedExercises.add(
        exercisesDatabase[Random().nextInt(exercisesDatabase.length)],
      );
    }
    publicPlan.days.add(
      TrainingDay(
        exercises: [],
        suggestedExercises: suggestedExercises,
        name: "Day ${publicPlan.days.length + 1}",
      ),
    );

    emit(
      PublicPlanEditing(
        publicPlan: publicPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  void changeDayName(int index, String newName) {
    if (index >= 0 && index < publicPlan.days.length) {
      publicPlan.days[index].name = newName;
      emit(
        PublicPlanEditing(
          publicPlan: publicPlan,
          lastUpdated: DateTime.now(),
          exercisesDatabase: exercisesDatabase,
        ),
      );
    }
  }

  void addExercise(int dayIndex, Exercise newExercise) {
    if (publicPlan.days[dayIndex].exercises.any(
      (exercise) => exercise.id == newExercise.id,
    )) {
      return;
    }
    if (dayIndex >= 0 && dayIndex < publicPlan.days.length) {
      UserExercise exercise = UserExercise(
        name: newExercise.name,
        minutes: 2,
        id: newExercise.id,
        bodyParts: newExercise.bodyParts,
        sets: [
          ExerciseSet(reps: 8, rir: 2, weight: 0),
          ExerciseSet(reps: 8, rir: 2, weight: 0),
          ExerciseSet(reps: 8, rir: 2, weight: 0),
        ],
      );
      publicPlan.days[dayIndex].exercises.add(exercise);

      // Update suggested exercises
      publicPlan.days[dayIndex].suggestedExercises = [];
      for (
        var i = 0;
        i < exercisesDatabase.length &&
            publicPlan.days[dayIndex].suggestedExercises.length < 5;
        i++
      ) {
        int randomInt = Random().nextInt(exercisesDatabase.length);
        if (exercisesDatabase[randomInt].bodyParts.any(
              (part) => exercise.bodyParts.contains(part),
            ) &&
            !(publicPlan.days[dayIndex].exercises.any(
              (ex) => ex.id == exercisesDatabase[randomInt].id,
            ))) {
          publicPlan.days[dayIndex].suggestedExercises.add(
            exercisesDatabase[randomInt],
          );
        }
      }

      emit(PublicPlansInitial());
      emit(
        PublicPlanEditing(
          publicPlan: publicPlan,
          lastUpdated: DateTime.now(),
          exercisesDatabase: exercisesDatabase,
        ),
      );
    }
  }

  void deleteExercise(String id) {
    for (var day in publicPlan.days) {
      day.exercises.removeWhere((exercise) => exercise.id == id);
    }
    emit(
      PublicPlanEditing(
        publicPlan: publicPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  void addSet(String id) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        print(
          'Checking exercise with id: ${day.exercises[i].id} with target id: $id',
        );
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?.add(ExerciseSet(reps: 8, rir: 2, weight: 0));
          emit(
            PublicPlanEditing(
              publicPlan: publicPlan,
              lastUpdated: DateTime.now(),
              exercisesDatabase: exercisesDatabase,
            ),
          );
          return;
        }
      }
    }
  }

  void deleteLastIndexSet(String id) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          if (day.exercises[i].sets!.isNotEmpty) {
            day.exercises[i].sets!.removeLast();
            emit(
              PublicPlanEditing(
                publicPlan: publicPlan,
                lastUpdated: DateTime.now(),
                exercisesDatabase: exercisesDatabase,
              ),
            );
          }
          return;
        }
      }
    }
  }

  void updateSetReps(String id, int reps, int index) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(reps: reps);
          emit(
            PublicPlanEditing(
              publicPlan: publicPlan,
              lastUpdated: DateTime.now(),
              exercisesDatabase: exercisesDatabase,
            ),
          );
          return;
        }
      }
    }
  }

  void changeSetWeight(String id, int weight, int index) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(weight: weight);
          emit(
            PublicPlanEditing(
              publicPlan: publicPlan,
              lastUpdated: DateTime.now(),
              exercisesDatabase: exercisesDatabase,
            ),
          );
          return;
        }
      }
    }
  }

  void updateSetRIR(String id, int rir, int index) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].sets?[index] = day.exercises[i].sets![index]
              .copyWith(rir: rir);
          emit(
            PublicPlanEditing(
              publicPlan: publicPlan,
              lastUpdated: DateTime.now(),
              exercisesDatabase: exercisesDatabase,
            ),
          );
          return;
        }
      }
    }
  }

  void updateRestTime(String id, int minutes, int seconds) {
    for (var day in publicPlan.days) {
      for (var i = 0; i < day.exercises.length; i++) {
        if (day.exercises[i].id == id) {
          day.exercises[i].minutes = minutes;
          day.exercises[i].seconds = seconds;
          emit(
            PublicPlanEditing(
              publicPlan: publicPlan,
              lastUpdated: DateTime.now(),
              exercisesDatabase: exercisesDatabase,
            ),
          );
          return;
        }
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
    emit(PublicPlanSearchingExercises(exercises: results, query: query));
  }

  void clearSearch() {
    emit(
      PublicPlanEditing(
        publicPlan: publicPlan,
        lastUpdated: DateTime.now(),
        exercisesDatabase: exercisesDatabase,
      ),
    );
  }

  Future<void> savePublicPlan() async {
    try {
      emit(PublicPlanUploading());
      final isEditing = publicPlan.id != null;
      final response = await apiService.post(
        isEditing ? '/edit-training-plan' : '/add-training-plan',
        isEditing
            ? {'updatedPlan': publicPlan.toJson(), 'id': publicPlan.id}
            : publicPlan.toJson(),
      );

      print(publicPlan.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadPlans();
      } else {
        emit(
          PublicPlansError(
            message:
                isEditing ? 'Failed to update plan' : 'Failed to create plan',
          ),
        );
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }
}
