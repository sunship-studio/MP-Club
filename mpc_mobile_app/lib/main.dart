import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/core/theme/theme.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/repositories/auth.dart';
import 'package:mpc_mobile_app/routes/auth.dart';
import 'package:mpc_mobile_app/routes/main.dart';

bool debugMode = false;

void main(List<String> args) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(MpcApp());
}

class MpcApp extends StatelessWidget {
  const MpcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: BlocProvider(
        // Global AuthCubit - checks authentication status
        create:
            (_) => AuthCubit(
              authRepository: getIt<AuthRepository>(),
              tokenStorage: getIt<TokenStorage>(),
            )..checkAuthStatus(), // Check on app start
        child: AuthStateHandler(),
      ),
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          // Still checking authentication
          AuthInitial() || AuthLoading() => _buildLoadingApp(),

          // User is authenticated - Show main app
          AuthAuthenticated(:final user) => _buildMainApp(user),

          // User is not authenticated - Show auth flow
          AuthUnauthenticated() ||
          EmailCheckSuccess() ||
          EmailCheckLoading() ||
          ForgotPasswordLoading() => _buildAuthApp(),

          // Error checking auth - treat as unauthenticated
          AuthError() => _buildAuthApp(),

          // Fallback to loading screen
          _ => _buildLoadingApp(),
        };
      },
    );
  }

  // Loading screen while checking auth
  Widget _buildLoadingApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkScaffoldColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 180.w),
              SizedBox(height: 20.h),
              Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Main app for authenticated users
  Widget _buildMainApp(User user) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: getIt<MainRouter>().router, // Main router with all screens
    );
  }

  // Auth app for unauthenticated users
  Widget _buildAuthApp() {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Your App - Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig:
          getIt<AuthRouter>().router, // Auth router (login, signup, etc)
    );
  }
}
