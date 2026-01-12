import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';
import 'package:mpc_admin_app/core/widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 100),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  icon: Coolicons.group,
                  onPressed: () {
                    context.push(RouteNames.waitingList);
                  },
                  label: 'WAITING LIST',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  icon: Icons.wifi,
                  onPressed: () {
                    context.push(RouteNames.onlineCoaching);
                  },
                  label: 'ONLINE COACHING',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  icon: Icons.fitness_center,
                  onPressed: () {
                    context.push(RouteNames.trainingPlans);
                  },
                  label: 'PLANS FOR SALE',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ModernButton(
                  icon: Icons.people,
                  onPressed: () {
                    context.push(RouteNames.groupClasses);
                  },
                  label: 'GROUP CLASSES',
                ),
              ),
            ],
          ),
        ),
        const Positioned(top: 20, right: 20, child: ThemeToggleButton()),
      ],
    );
  }
}
