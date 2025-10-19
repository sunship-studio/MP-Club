import 'package:get_it/get_it.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';

final getIt = GetIt.instance;

void setupLocator() async {
  getIt.registerFactory<TrainingPlanCubit>(() => TrainingPlanCubit());
}
