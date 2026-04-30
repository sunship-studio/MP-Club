import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/repositories/auth.dart';
import 'package:mpc_mobile_app/services/notification_service.dart';
import 'package:mpc_mobile_app/services/socket.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository, required this.tokenStorage})
    : super(AuthInitial());
  AuthRepository authRepository;
  TokenStorage tokenStorage;

  Future<void> loadUser() async {
    try {
      final user = await authRepository.getUser();
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Error('Failed to load user: $e'));
    }
  }

  Future<void> logout() async {
    try {
      // 1. Remove FCM token from backend (before deleting auth tokens)
      final notificationService = getIt<NotificationService>();
      await notificationService.removeToken();
      print('✅ FCM token removed from backend');
    } catch (e) {
      print('⚠️ Error removing FCM token (continuing with logout): $e');
      // Don't block logout if FCM removal fails
    }

    try {
      // 2. Disconnect socket
      final socketService = getIt<SocketService>();
      socketService.disconnect();
      print('✅ Socket disconnected');
    } catch (e) {
      print('⚠️ Error disconnecting socket: $e');
    }

    // 3. Clear local tokens
    await tokenStorage.deleteTokens();

    // 4. Update auth state
    emit(Unauthenticated());
  }

  Future<void> checkEmail(String email) async {
    emit(EmailCheckLoading());
    final response = await authRepository.checkEmail(email);
    if (response.success) {
      emit(
        EmailCheckSuccess(
          exists: response.data!['exists'],
          hasPassword:
              response.data!['hasPassword'] ?? response.data!['exists'],
        ),
      );
    } else {
      emit(EmailCheckError(response.message ?? 'Error checking email'));
    }
  }

  Future<void> setPassword(String email, String password) async {
    emit(AuthLoading());
    authRepository.setPassword(email, password).then((result) async {
      if (result.success) {
        emit(SetPasswordSuccess());
        loadUser();

        // Register FCM token after setting password (new account)
        _registerFCMToken();
      } else {
        emit(SetPasswordError(result.message ?? 'Error setting password'));
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await authRepository.login(email, password);
      if (result.success) {
        final user = await authRepository.getUser();
        emit(Authenticated(user: user));

        // Register FCM token after successful login
        _registerFCMToken();
        return;
      } else {
        emit(Error(result.message ?? 'Error logging in'));
        return;
      }
    } catch (e) {
      emit(
        Error('Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final tokens = await tokenStorage.getAccessToken();
    if (tokens != null) {
      // Validate token by fetching user data
      try {
        print('fetching user');
        User user = await authRepository.getUser();
        print('got user: ${user.email}');
        emit(Authenticated(user: user));
      } catch (e) {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> setNewPassword(String token, String password) async {
    emit(AuthLoading());
    final user = await authRepository.setNewPassword(token, password);
    if (user != null) {
      emit(SetNewPasswordSuccess());
      emit(Authenticated(user: user));
    } else {
      emit(SetNewPasswordError('Error resetting password'));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(ForgotPasswordLoading());
    final result = await authRepository.forgotPassword(email);
    if (result.success) {
      emit(ForgotPasswordSuccess());
      emit(Unauthenticated());
    } else {
      emit(ForgotPasswordError(result.message ?? 'Error sending reset link'));
    }
  }

  /// Create account with Apple subscription
  Future<void> createAccountWithAppleSubscription({
    required String email, // Optional - backend extracts from receipt
    required String firstName,
    required String lastName,
    required int age,
    required String appleReceiptData,
    required String subscriptionId,
    int? targetWeight,
  }) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.createAccountWithAppleSubscription(
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        appleReceiptData: appleReceiptData,
        subscriptionId: subscriptionId,
        targetWeight: targetWeight,
      );

      if (result.success) {
        // Account created and tokens saved
        // Now fetch the user data
        final user = await authRepository.getUser();
        emit(Authenticated(user: user));

        // Register FCM token after account creation
        _registerFCMToken();
      } else {
        emit(Error(result.message ?? 'Failed to create account'));
      }
    } catch (e) {
      emit(Error('Error creating account: $e'));
    }
  }

  /// Register FCM token with backend (called after login/signup)
  /// Note: Socket service also auto-registers on connection,
  /// but this ensures early registration
  Future<void> _registerFCMToken() async {
    try {
      final notificationService = getIt<NotificationService>();
      final fcmToken = notificationService.fcmToken;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        print('📤 Registering FCM token after authentication...');
        await notificationService.registerToken(fcmToken);
        print('✅ FCM token registered successfully');
      } else {
        print(
          '⚠️ No FCM token available yet (will register when socket connects)',
        );
      }
    } catch (e) {
      print('⚠️ Error registering FCM token: $e');
      // Don't block auth flow if FCM registration fails
    }
  }
}

class AuthState {
  const AuthState();
}

// Set first time password
class SetPasswordError extends AuthState {
  final String message;
  const SetPasswordError(this.message);
}

class SetPasswordSuccess extends AuthState {
  const SetPasswordSuccess();
}

// Reset password
class SetNewPasswordSuccess extends AuthState {
  const SetNewPasswordSuccess();
}

class SetNewPasswordError extends AuthState {
  final String message;
  const SetNewPasswordError(this.message);
}

// Forgot password
class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

class ForgotPasswordLoading extends AuthState {
  const ForgotPasswordLoading();
}

class ForgotPasswordError extends AuthState {
  final String message;
  const ForgotPasswordError(this.message);
}

// Email check
class EmailCheckSuccess extends AuthState {
  final bool exists;
  final bool hasPassword;

  const EmailCheckSuccess({required this.exists, required this.hasPassword});
}

class EmailCheckLoading extends AuthState {}

class EmailCheckError extends AuthState {
  final String message;
  const EmailCheckError(this.message);
}

class Error extends AuthState {
  final String message;
  const Error(this.message);
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated({required this.user});
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthLoading extends AuthState {}

class AuthInitial extends AuthState {}
