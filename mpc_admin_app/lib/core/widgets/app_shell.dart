import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/theme/cubit.dart';
import 'package:mpc_admin_app/app/bloc/theme/state.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/theme/design_system.dart';

/// A persistent shell that wraps all app screens with consistent header
class AppShell extends StatefulWidget {
  AppShell({
    super.key,
    required this.child,
    required this.showBackButton,
    this.radius = true,
  });

  final Widget child;
  final bool showBackButton;
  bool radius;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // CHANGED: allow keyboard to resize
      body: Container(
        child: SafeArea(
          top: true,
          bottom: false,
          // ADDED: SafeArea here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      widget.radius ? kBorderRadiusMedium : 0,
                    ),
                    bottomRight: Radius.circular(
                      widget.radius ? kBorderRadiusMedium : 0,
                    ),
                  ),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.showBackButton
                        ? Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(RouteNames.home);
                                }
                              },
                              icon: Icon(
                                Coolicons.chevron_big_left,
                                size: 30,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                        )
                        : Expanded(child: Container()),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder:
                          (context, state) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Image.asset(
                              state is ThemeDarkState
                                  ? "assets/logo_dark.png"
                                  : 'assets/logo.png',
                            ),
                          ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
              // Content area - this changes based on route
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}
