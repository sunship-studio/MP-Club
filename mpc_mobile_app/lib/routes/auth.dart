import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/presentation/screens/forgot_password.dart';
import 'package:mpc_mobile_app/presentation/screens/login.dart';
import 'package:mpc_mobile_app/presentation/screens/new_password.dart';
import 'package:mpc_mobile_app/presentation/screens/set_password.dart';
import 'package:mpc_mobile_app/presentation/screens/subscription_signup.dart';
import 'package:mpc_mobile_app/presentation/screens/welcome.dart';

class AuthRouter {
  AuthRouter();

  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
        routes: [
          GoRoute(
            path: 'set_password',
            builder:
                (context, state) =>
                    SetPasswordScreen(email: state.extra as String),
          ),
          GoRoute(
            path: 'forgot_password',
            builder:
                (context, state) =>
                    ForgotPasswordScreen(email: state.extra as String),
          ),
          GoRoute(
            path: 'new_password',
            builder:
                (context, state) =>
                    NewPasswordScreen(token: state.extra as String),
          ),
          GoRoute(
            path: 'subscription_signup',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              return SubscriptionSignupScreen(
                receipt: data['receipt'] as String,
                subscriptionId: data['subscriptionId'] as String,
              );
            },
          ),
          GoRoute(
            path: 'welcome',
            builder: (context, state) => WelcomeScreen(),
          ),
        ],
      ),
    ],
  );
}
