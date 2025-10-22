import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/onboarding/onboarding_input.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _showPassword = false;
  String? _email;
  final TextEditingController _emailController = TextEditingController();
  final bool _deeomLinkHandled = false;
  final TextEditingController _passwordController = TextEditingController();
  // Track processed links to avoid duplicates
  final Set<String> _processedLinks = {};
  final AppLinks _appLinks = AppLinks();
  final bool _initialLinkProcessed = false;

  @override
  void initState() {
    super.initState();

    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('🔗 Incoming link: $uri');

        // Skip if this is a duplicate (already processed as initial link)
        final linkKey = uri.toString();
        if (_processedLinks.contains(linkKey)) {
          print('⏭️ Skipping duplicate link');
          return;
        }

        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    final linkKey = uri.toString();

    // Check if already processed
    if (_processedLinks.contains(linkKey)) {
      print('⏭️ Link already processed: $linkKey');
      return;
    }

    // Mark as processed
    _processedLinks.add(linkKey);

    // Clean up old processed links (keep last 10)
    if (_processedLinks.length > 10) {
      _processedLinks.remove(_processedLinks.first);
    }

    print('Processing deep link: $uri');

    // Wait for navigator to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToDeepLink(uri);
    });
  }

  void _navigateToDeepLink(Uri uri) {
    if (context.mounted == false) {
      print('⚠️ Navigator not ready, retrying...');
      Future.delayed(Duration(milliseconds: 500), () {
        _navigateToDeepLink(uri);
      });
      return;
    }

    // Parse the deep link
    if (uri.host == 'reset-password' || uri.path == '/reset-password') {
      final token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        // Check if we're already on the reset password screen
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute == '/login/new_password') {
          print('⏭️ Already on reset password screen, skipping navigation');
          return;
        }
        print(
          '✅ Navigating to reset password with token: ${token.substring(0, 10)}...',
        );

        // Navigate
        context.go('/login/new_password', extra: token);
      } else {
        print('❌ No token found in deep link');
      }
    } else {
      print('❌ Unknown deep link path: ${uri.host}${uri.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is EmailCheckSuccess &&
              state.exists &&
              !state.hasPassword) {
            // Navigate to set password screen
            context.go('/login/set_password', extra: _emailController.text);
          } else if (state is AuthError) {
            // Show error snackbar
            SnackBarService.show(
              context: context,
              message: state.message,
              isNavBar: false,
              isError: true,
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Container(
              margin: EdgeInsets.only(bottom: bottomPadding(context)),

              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: topPadding(context)),
                            color: Colors.black,
                            child: Image.asset(
                              'assets/images/login_header.png',
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 140,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),

                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 24.h),
                              child: Column(
                                children: [
                                  Text(
                                    "WELCOME TO MPC",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      letterSpacing: -0.9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: 6),
                                  Text(
                                    "Let's become more stronger today",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            OnboardingInput(
                              validator: Constants.emailValidator,
                              controller: _emailController,
                              enabled:
                                  !(state is EmailCheckSuccess && state.exists),
                              label: "Email Address",
                              hintText: "Email address...",
                            ),

                            state is EmailCheckSuccess && !state.exists
                                ? Text(
                                  "Email not found. Please purchase a membership to create an account.",
                                  style: TextStyle(
                                    color: AppColors.redColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.6,
                                  ),
                                )
                                : SizedBox.shrink(),

                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 900),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, -0.3),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child:
                                  state is EmailCheckSuccess && state.exists ||
                                          state is AuthError ||
                                          state is AuthLoading
                                      ? GestureDetector(
                                        onTap: () {
                                          // Navigate to forgot password screen
                                          context.go(
                                            '/login/forgot_password',
                                            extra: _emailController.text,
                                          );
                                        },
                                        child: Container(
                                          key: ValueKey('password'),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              OnboardingInput(
                                                controller: _passwordController,
                                                label: "Password",
                                                hintText: "Input Password",
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Forgot Password?",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 1),
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.white,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -0.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      : SizedBox.shrink(key: ValueKey('empty')),
                            ),
                            SizedBox(height: 12.h),
                            CircularButton(
                              label: "Sign In",

                              dark: false,
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  switch (state) {
                                    case AuthLoading():
                                      return;
                                    case EmailCheckSuccess() || AuthError():
                                      if (state is EmailCheckSuccess &&
                                              state.exists ||
                                          state is AuthError) {
                                        await context.read<AuthCubit>().login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                      } else {
                                        await context
                                            .read<AuthCubit>()
                                            .checkEmail(_emailController.text);
                                      }
                                      break;
                                    default:
                                      // Check email
                                      await context
                                          .read<AuthCubit>()
                                          .checkEmail(_emailController.text);
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.6,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Purchase a Membership",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 1),
                                fontSize: 14.sp,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          state is EmailCheckSuccess && state.exists
                              ? 24.h
                              : MediaQuery.of(context).size.height * 0.145,
                    ),
                    Text(
                      "Accounts are created via membership purchase on the",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      "Private Website",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 1),
                        fontSize: 12.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
