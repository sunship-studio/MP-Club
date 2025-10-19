import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/repositories/auth.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository, required this.tokenStorage})
    : super(AuthInitial());
  AuthRepository authRepository;
  TokenStorage tokenStorage;

  Future<void> loadUser() async {
    try {
      final user = await authRepository.getUser();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError('Failed to load user: $e'));
    }
  }

  Future<void> logout() async {
    await tokenStorage.deleteTokens();

    emit(AuthUnauthenticated());
  }

  Future<void> checkEmail(String email) async {
    emit(EmailCheckLoading());
    final response = await authRepository.checkEmail(email);
    if (response.success) {
      emit(
        EmailCheckSuccess(
          exists: response.data!['exists'],
          hasPassword: response.data!['hasPassword'],
        ),
      );
    } else {
      emit(EmailCheckError(response.message ?? 'Error checking email'));
    }
  }

  Future<void> setPassword(String email, String newPassword) async {
    emit(AuthLoading());
    authRepository.setPassword(email, newPassword).then((result) async {
      if (result.success) {
        emit(SetPasswordSuccess());
        loadUser();
      } else {
        emit(SetPasswordError(result.message ?? 'Error setting password'));
      }
    });
  }

  Future<void> login(String email, String password) async {
    final result = await authRepository.login(email, password);
    if (result.success) {
      final user = await authRepository.getUser();
      emit(AuthAuthenticated(user: user));
      return;
    } else {
      emit(AuthError(result.message ?? 'Error logging in'));
      return;
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
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
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

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {}

class AuthInitial extends AuthState {}
