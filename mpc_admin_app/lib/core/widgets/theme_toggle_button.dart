import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coolicons/coolicons.dart';
import 'package:mpc_admin_app/app/bloc/theme/cubit.dart';
import 'package:mpc_admin_app/app/bloc/theme/state.dart';
import 'package:mpc_admin_app/core/theme/design_system.dart';

/// Theme toggle button with smooth animation
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kAnimationStandard,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state is ThemeDarkState;

        return GestureDetector(
          onTap: () {
            _controller.forward(from: 0);
            context.read<ThemeCubit>().toggleTheme();
          },
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159, // 180 degrees
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    shape: BoxShape.circle,
                    boxShadow: kShadowMedium(context),
                  ),
                  child: Icon(
                    isDark ? Coolicons.moon : Coolicons.sun,
                    color: Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
