import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';

/// A persistent shell that wraps all app screens with consistent header
class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // CHANGED: allow keyboard to resize
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 17, 138, 194), Colors.black],
          ),
        ),
        child: SafeArea(
          // ADDED: SafeArea here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ), // CHANGED: simplified padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius ? 10 : 0),
                    bottomRight: Radius.circular(radius ? 10 : 0),
                  ),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showBackButton
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
                              icon: const Icon(
                                Coolicons.chevron_big_left,
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        : Expanded(child: Container()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset('assets/logo.png'),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
              // Content area - this changes based on route
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
