import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/models/tutorial.dart';
import 'package:mpc_mobile_app/data/repositories/tutorials.dart';

class TutorialCubit extends Cubit<TutorialState> {
  final TutorialRepository tutorialsRepository;

  TutorialCubit({required this.tutorialsRepository})
    : super(TutorialsInitial());

  Future<void> searchTutorials({required String query}) async {
    emit(TutorialsLoading());
    try {
      final tutorials = await tutorialsRepository.searchTutorials(query: query);
      emit(TutorialsLoaded(tutorials: tutorials));
    } catch (e) {
      emit(TutorialsError(message: e.toString()));
    }
  }

  void clearSearch() {
    emit(TutorialsInitial());
  }
}

class TutorialState {}

class TutorialsInitial extends TutorialState {}

class TutorialsLoading extends TutorialState {}

class TutorialsLoaded extends TutorialState {
  final List<Tutorial> tutorials;

  TutorialsLoaded({required this.tutorials});
}

class TutorialsError extends TutorialState {
  final String message;

  TutorialsError({required this.message});
}
