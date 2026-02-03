import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/exercises/state.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class ExercisesCubit extends Cubit<ExercisesState> {
  ExercisesCubit() : super(ExercisesInitial());

  List<Exercise> _allExercises = [];

  static const List<String> bodyPartOptions = [
    'Quadriceps',
    'Glutes',
    'Hamstrings',
    'Calves',
    'Abductors',
    'Adductors',
    'Chest',
    'Upper Chest',
    'Back',
    'Lats',
    'Shoulders',
    'Rear Delts',
    'Traps',
    'Lower Back',
    'Biceps',
    'Triceps',
    'Core',
  ];

  Future<void> loadExercises() async {
    emit(ExercisesLoading());

    try {
      final response = await apiService.get('/exercises');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        _allExercises = data.map((json) => Exercise.fromJson(json)).toList();

        // Sort alphabetically by name
        _allExercises.sort((a, b) => a.name.compareTo(b.name));

        emit(
          ExercisesLoaded(
            exercises: _allExercises,
            filteredExercises: _allExercises,
          ),
        );
      } else {
        emit(const ExercisesError(message: 'Failed to load exercises'));
      }
    } catch (e) {
      emit(ExercisesError(message: e.toString()));
    }
  }

  void filterExercises({String? query, String? bodyPart}) {
    if (state is! ExercisesLoaded) return;

    final currentState = state as ExercisesLoaded;
    final searchQuery = query ?? currentState.searchQuery;
    final selectedBodyPart = bodyPart;

    List<Exercise> filtered = _allExercises;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
    }

    // Filter by body part
    if (selectedBodyPart != null && selectedBodyPart.isNotEmpty) {
      filtered =
          filtered
              .where((e) => e.bodyParts.contains(selectedBodyPart))
              .toList();
    }

    emit(
      currentState.copyWith(
        filteredExercises: filtered,
        searchQuery: searchQuery,
        selectedBodyPart: selectedBodyPart,
      ),
    );
  }

  Future<bool> createExercise({
    required String name,
    String? description,
    required List<String> bodyParts,
    String? videoPath,
    String? imagePath,
  }) async {
    emit(const ExerciseSaving());

    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description ?? '',
        'bodyParts': bodyParts,
      });

      if (videoPath != null) {
        formData.files.add(
          MapEntry('video', await MultipartFile.fromFile(videoPath)),
        );
      }

      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await apiService.postFormData(
        endpoint: '/create-exercise',
        formData: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          emit(ExerciseSaving(uploadProgress: progress));
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(const ExerciseSaved(message: 'Exercise created successfully'));
        await loadExercises();
        return true;
      } else {
        emit(const ExercisesError(message: 'Failed to create exercise'));
        return false;
      }
    } catch (e) {
      emit(ExercisesError(message: e.toString()));
      return false;
    }
  }

  Future<bool> updateExercise({
    required String id,
    required String name,
    String? description,
    required List<String> bodyParts,
    String? videoPath,
    String? imagePath,
    String? existingVideoUrl,
    String? existingImageUrl,
  }) async {
    emit(const ExerciseSaving());

    try {
      final formData = FormData.fromMap({
        'id': id,
        'name': name,
        'description': description ?? '',
        'bodyParts': bodyParts,
        'existingVideoUrl': existingVideoUrl ?? '',
        'existingImageUrl': existingImageUrl ?? '',
      });

      if (videoPath != null) {
        formData.files.add(
          MapEntry('video', await MultipartFile.fromFile(videoPath)),
        );
      }

      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await apiService.postFormData(
        endpoint: '/update-exercise',
        formData: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          emit(ExerciseSaving(uploadProgress: progress));
        },
      );

      if (response.statusCode == 200) {
        emit(const ExerciseSaved(message: 'Exercise updated successfully'));
        await loadExercises();
        return true;
      } else {
        emit(const ExercisesError(message: 'Failed to update exercise'));
        return false;
      }
    } catch (e) {
      emit(ExercisesError(message: e.toString()));
      return false;
    }
  }

  Future<bool> deleteExercise(String id) async {
    emit(ExercisesLoading());

    try {
      final response = await apiService.post('/delete-exercise', {'id': id});

      if (response.statusCode == 200) {
        emit(const ExerciseSaved(message: 'Exercise deleted successfully'));
        await loadExercises();
        return true;
      } else {
        emit(const ExercisesError(message: 'Failed to delete exercise'));
        return false;
      }
    } catch (e) {
      emit(ExercisesError(message: e.toString()));
      return false;
    }
  }
}
