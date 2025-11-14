import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/add_subscriber.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/cubit.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/services/socket.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/screens/add_subscriber.dart';
import 'package:mpc_admin_app/core/screens/chat.dart';
import 'package:mpc_admin_app/core/screens/home.dart';
import 'package:mpc_admin_app/core/screens/online_coaching.dart';
import 'package:mpc_admin_app/core/screens/training_plans.dart';
import 'package:mpc_admin_app/core/screens/waiting_list.dart';
import 'package:mpc_admin_app/core/widgets/app_shell.dart';
import 'package:mpc_admin_app/main.dart';

// Key for the shell navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Global router configuration for the app
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    // Shell route - provides persistent header for all routes except chat
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // Determine if back button should show based on current location
        final showBackButton = state.uri.path != RouteNames.home;

        return AppShell(showBackButton: showBackButton, child: child);
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          pageBuilder:
              (context, state) => NoTransitionPage(child: const HomeScreen()),
        ),
        GoRoute(
          path: RouteNames.waitingList,
          name: 'waitingList',
          pageBuilder:
              (context, state) => NoTransitionPage(child: const WaitingList()),
        ),
        GoRoute(
          path: RouteNames.onlineCoaching,
          name: 'onlineCoaching',
          pageBuilder: (context, state) {
            // Initialize socket when navigating to online coaching
            SocketService().connect(
              debug
                  ? 'http://localhost:3500'
                  : "wss://mp-club-production.up.railway.app",
              admin_key,
            );

            return const NoTransitionPage(child: OnlineCoaching());
          },
        ),
        GoRoute(
          path: RouteNames.checkIns,
          name: 'checkIns',
          pageBuilder: (context, state) {
            final user = state.extra as User?;
            return NoTransitionPage(
              child: OnlineCoaching(checkIns: true, user: user),
            );
          },
        ),
        GoRoute(
          path: RouteNames.planEditor,
          name: 'planEditor',
          pageBuilder: (context, state) {
            final user = state.extra as User?;
            return NoTransitionPage(
              child: OnlineCoaching(planEditor: true, user: user),
            );
          },
        ),
        GoRoute(
          path: RouteNames.addSubscriber,
          name: 'addSubscriber',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: BlocProvider(
                create: (context) => AddSubscribeCubit(),
                child: AddSubscriberScreen(),
              ),
            );
          },
        ),
        GoRoute(
          path: RouteNames.trainingPlans,
          name: 'trainingPlans',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: BlocProvider(
                create: (context) => PublicPlansCubit(),
                child: const TrainingPlansScreen(),
              ),
            );
          },
        ),
      ],
    ),
    // Chat route - outside shell, has its own custom UI
    GoRoute(
      path: RouteNames.chat,
      name: 'chat',
      builder: (context, state) {
        final user = state.extra as User?;
        return ChatScreen(user: user, isAdmin: true);
      },
    ),
  ],
);
