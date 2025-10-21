import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/data/repositories/auth.dart';
import 'package:mpc_mobile_app/data/repositories/calories.dart';
import 'package:mpc_mobile_app/data/repositories/check_in.dart';
import 'package:mpc_mobile_app/data/repositories/profile.dart';
import 'package:mpc_mobile_app/data/repositories/workout.dart';
import 'package:mpc_mobile_app/routes/auth.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ==================== EXTERNAL DEPENDENCIES ====================

  getIt.registerSingleton<Connectivity>(Connectivity());
  // ==================== STORAGE ====================
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  // // Custom Dio client wrapper (optional)
  // Dio instance with interceptors
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3500/mobile-app',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    // dio.interceptors.add(getIt<AuthInterceptor>());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  });

  getIt.registerSingleton<DioClient>(
    DioClient(getIt<Dio>(), getIt<TokenStorage>()),
  );
  //  SOCKET SERVICE
  getIt.registerLazySingleton<SocketService>(() => SocketService());

  // ==================== REPOSITORIES ====================
  // Singleton = One instance for entire app lifetime

  getIt.registerLazySingleton<CheckInRepository>(
    () => CheckInRepository(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dio: getIt<DioClient>(),
      storage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<CaloriesRepository>(
    () => CaloriesRepository(dio: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepository(dio: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(dioClient: getIt<DioClient>()),
  );

  // ROUTERS
  getIt.registerSingleton<AuthRouter>(AuthRouter());
  getIt.registerSingleton<MainRouter>(MainRouter());
}
