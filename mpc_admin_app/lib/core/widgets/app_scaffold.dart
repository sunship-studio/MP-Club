import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';

/// A custom scaffold that provides consistent app chrome (header with logo and back button)
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.showHeader = true,
    this.showBackButton = false,
  });

  final Widget body;
  final bool showHeader;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 17, 138, 194), Colors.black],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Container(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
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
                  ],
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
