import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/calories.dart';
import 'package:mpc_mobile_app/cubits/check_in.dart';
import 'package:mpc_mobile_app/cubits/profile.dart';
import 'package:mpc_mobile_app/cubits/workout.dart';
import 'package:mpc_mobile_app/data/models/TrainingDay.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/data/repositories/calories.dart';
import 'package:mpc_mobile_app/data/repositories/check_in.dart';
import 'package:mpc_mobile_app/data/repositories/profile.dart';
import 'package:mpc_mobile_app/data/repositories/workout.dart';
import 'package:mpc_mobile_app/presentation/screens/active_workout.dart';
import 'package:mpc_mobile_app/presentation/screens/calorties.dart';
import 'package:mpc_mobile_app/presentation/screens/chat.dart';
import 'package:mpc_mobile_app/presentation/screens/check_in.dart';
import 'package:mpc_mobile_app/presentation/screens/check_in_info.dart';
import 'package:mpc_mobile_app/presentation/screens/home.dart';
import 'package:mpc_mobile_app/presentation/screens/profile.dart';
import 'package:mpc_mobile_app/presentation/screens/submit_checkin.dart';
import 'package:mpc_mobile_app/presentation/screens/training_plan.dart';

GlobalKey<MpcAppNavBarState> navBarKey = GlobalKey<MpcAppNavBarState>();

class MainRouter {
  MainRouter();
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) => MpcAppNavBar(
              key: navBarKey,
              navigationShell: navigationShell,
              child: navigationShell,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/home",
                builder: (context, state) => HomeScreen(),
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder:
                        (context, state) => BlocProvider(
                          create:
                              (context) => ProfileCubit(
                                profileRepository: getIt<ProfileRepository>(),
                              ),
                          child: ProfileScreen(),
                        ),
                  ),
                  GoRoute(
                    path: '/chat',
                    builder:
                        (context, state) =>
                            ChatScreen(user: state.extra as User),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/training_plan',
                builder:
                    (context, state) => BlocProvider(
                      create:
                          (context) => WorkoutCubit(
                            workoutRepository: getIt<WorkoutRepository>(),
                          ),
                      child: TrainingPlanScreen(),
                    ),

                routes: [
                  GoRoute(
                    path: '/workout',
                    builder:
                        (context, state) => ActiveWorkoutScreen(
                          trainingDay: state.extra as TrainingDay,
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutorials',
                builder:
                    (context, state) => Scaffold(
                      body: Center(
                        child: Text("Tutorials Coming By the End of 2025"),
                      ),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/check_in',
                builder: (context, state) => CheckInScreen(),
                routes: [
                  GoRoute(
                    path: 'info',
                    builder: (context, state) => CheckInInfoScreen(),
                  ),
                  GoRoute(
                    path: 'submit',
                    builder:
                        (context, state) => BlocProvider(
                          create:
                              (context) =>
                                  CheckInCubit(getIt<CheckInRepository>()),
                          child: SubmitCheckInScreen(),
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calories',
                builder:
                    (context, state) => BlocProvider(
                      create:
                          (context) => CaloriesCubit(
                            caloriesRepository: getIt<CaloriesRepository>(),
                          ),
                      child: CaloriesScreen(),
                    ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MpcAppNavBar extends StatefulWidget {
  const MpcAppNavBar({super.key, this.child, required this.navigationShell});

  final Widget? child;
  final StatefulNavigationShell navigationShell;

  @override
  State<MpcAppNavBar> createState() => MpcAppNavBarState();
}

class MpcAppNavBarState extends State<MpcAppNavBar> {
  void toggleNavBar() {
    setState(() {
      showNavBar = !showNavBar;
    });
  }

  void switchPage(int index) {
    widget.navigationShell.goBranch(index);
    setState(() {
      selectedIndex = index;
    });
  }

  bool showNavBar = true;
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (showNavBar)
          Align(
            alignment: Alignment.bottomCenter,
            child: MpcNavBar(
              navigationShell: widget.navigationShell,
              selectedIndex: selectedIndex,
              onItemTap: (index) {
                switchPage(index);
              },
            ),
          ),
      ],
    );
  }
}

class MpcNavBar extends StatefulWidget {
  MpcNavBar({
    super.key,
    required this.navigationShell,
    required this.selectedIndex,
    required this.onItemTap,
  });
  StatefulNavigationShell navigationShell;
  Function(int) onItemTap;
  int selectedIndex = 0;
  @override
  State<MpcNavBar> createState() => _MpcNavBarState();
}

class _MpcNavBarState extends State<MpcNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Your app background color
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.r),
              color: Colors.white, // Nav bar background (not transparent)
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  isSelected: widget.selectedIndex == 0,
                  iconName: 'home',
                  onTap: () {
                    widget.onItemTap(0);
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: widget.selectedIndex == 1,
                  iconName: 'barbell',
                  onTap: () {
                    widget.onItemTap(1);
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: widget.selectedIndex == 2,
                  iconName: 'movie',
                  onTap: () {
                    widget.onItemTap(2);
                  },
                ),
                Gap(4.w),
                NavBarItem(
                  onTap: () {
                    widget.onItemTap(3);
                  },
                  iconName: 'checklist',
                  isSelected: widget.selectedIndex == 3,
                ),
                Gap(4.w),
                NavBarItem(
                  isSelected: widget.selectedIndex == 4,
                  iconName: 'soup',
                  onTap: () {
                    widget.onItemTap(4);
                  },
                ),
                // ... more nav items
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom - 5),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  NavBarItem({
    super.key,
    this.isSelected = true,
    this.iconName = 'home',
    required this.onTap,
  });
  Function() onTap;
  bool isSelected;
  String iconName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient:
              isSelected
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withAlpha(255),
                      Colors.grey[600]!.withAlpha(205),
                    ],
                  )
                  : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/$iconName.svg',
            width: 20.w,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : AppColors.greyTextColor,
              BlendMode.srcIn,
            ),
            height: 20.h,
          ),
        ),
      ),
    );
  }
}
