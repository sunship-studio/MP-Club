import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';
import 'package:mpc_mobile_app/data/models/tutorials_section.dart';
import 'package:mpc_mobile_app/data/repositories/exercise.dart';

class TutorialCubit extends Cubit<TutorialState> {
  final ExerciseRepository exerciseRepository;
  TutorialsSection? tutorialsSection;
  List<Exercise>? searchResults;
  TutorialCubit({required this.exerciseRepository}) : super(TutorialsInitial());

  Future<void> searchTutorials({required String query}) async {
    TutorialsSection tutorialsSection;
    if (state is! TutorialsSectionLoaded) {
      return;
    }

    emit(TutorialsLoading());
    try {
      final exercises = await exerciseRepository.searchExercises(query: query);
      searchResults = exercises;
      print(exercises);
      emit(
        TutorialsSectionLoaded(
          tutorialsSection: this.tutorialsSection!,
          searchResults: exercises,
        ),
      );
    } catch (e) {
      print(e);
      emit(TutorialsError(message: e.toString()));
    }
  }

  Future<void> searchByCategory({required String category}) async {
    TutorialsSection tutorialsSection;
    if (state is! TutorialsSectionLoaded && state is! TutorialsByCategoryLoaded) {
      return Future.value();
    }

    emit(TutorialsLoading());
    try {
      final exercises = await exerciseRepository.searchByCategory(
        category: category,
      );

      print(exercises);
      emit(
        TutorialsByCategoryLoaded(
          tutorialsByCategory: exercises,
          searchResults: searchResults,
          selectedCategory: category,
          tutorialsSection: this.tutorialsSection,
        ),
      );
    } catch (e) {
      print(e);
      emit(TutorialsError(message: e.toString()));
    }
    return Future.value();
  }

  Future<void> fetchTutorialsSection({required String userId}) async {
    emit(TutorialsLoading());
    print("tutorialsSection : $tutorialsSection");
    try {
      final tutorialsSection = await exerciseRepository.getTutorialsSection(
        userId: userId,
      );

      this.tutorialsSection = tutorialsSection;
      emit(TutorialsSectionLoaded(tutorialsSection: tutorialsSection));
    } catch (e) {
      emit(TutorialsError(message: e.toString()));
    }
  }

  void clearSearch() {
    if (tutorialsSection == null) {
      return;
    }
    emit(
      TutorialsSectionLoaded(
        tutorialsSection: tutorialsSection!,
        searchResults: null,
      ),
    );
  }

  void clearCategoryFilter() {
    if (tutorialsSection == null) {
      return;
    }
    emit(
      TutorialsSectionLoaded(
        tutorialsSection: tutorialsSection!,
        searchResults: null,
      ),
    );
  }
}

class TutorialState {}

class TutorialsInitial extends TutorialState {}

class TutorialsLoading extends TutorialState {}

class TutorialsError extends TutorialState {
  final String message;

  TutorialsError({required this.message});
}

class TutorialsSectionLoaded extends TutorialState {
  final TutorialsSection tutorialsSection;
  final List<Exercise>? searchResults;

  TutorialsSectionLoaded({required this.tutorialsSection, this.searchResults});
}

class TutorialsByCategoryLoaded extends TutorialState {
  final List<Exercise> tutorialsByCategory;
  final List<Exercise>? searchResults;
  final String selectedCategory;
  final TutorialsSection? tutorialsSection;

  TutorialsByCategoryLoaded({
    required this.tutorialsByCategory,
    required this.selectedCategory,
    this.searchResults,
    this.tutorialsSection,
  });
}
