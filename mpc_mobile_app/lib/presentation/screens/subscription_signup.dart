import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/onboarding/onboarding_input.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class SubscriptionSignupScreen extends StatefulWidget {
  final String receipt;
  final String subscriptionId;

  const SubscriptionSignupScreen({
    super.key,
    required this.receipt,
    required this.subscriptionId,
  });

  @override
  State<SubscriptionSignupScreen> createState() =>
      _SubscriptionSignupScreenState();
}

class _SubscriptionSignupScreenState extends State<SubscriptionSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final targetWeight =
          _targetWeightController.text.isNotEmpty
              ? int.tryParse(_targetWeightController.text)
              : null;

      final email =
          _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null;

      context.read<AuthCubit>().createAccountWithAppleSubscription(
        email:
            email, // Provide email if user entered it, otherwise backend extracts from receipt
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text),
        appleReceiptData: widget.receipt,
        subscriptionId: widget.subscriptionId,
        targetWeight: targetWeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Account created successfully, user is now logged in
            SnackBarService.show(
              context: context,
              message: 'Account created successfully!',
              isNavBar: false,
              isError: false,
            );
            // Navigation will be handled by main.dart AuthStateHandler
          } else if (state is AuthError) {
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
            final isLoading = state is AuthLoading;

            return Container(
              margin: EdgeInsets.only(top: topPadding(context)),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(25.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Complete Your Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Your subscription is confirmed! Please provide your details to complete account setup.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      OnboardingInput(
                        controller: _emailController,
                        label: 'Email (Optional)',
                        hintText: 'john@example.com',
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            // Basic email validation
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'We\'ll use your Apple account email if left blank',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      OnboardingInput(
                        controller: _firstNameController,
                        label: 'First Name',
                        hintText: 'John',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      SizedBox(height: 16.h),
                      OnboardingInput(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hintText: 'Doe',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      SizedBox(height: 16.h),
                      OnboardingInput(
                        controller: _ageController,
                        label: 'Age',
                        hintText: '25',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Age is required';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 13 || age > 120) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      SizedBox(height: 16.h),
                      OnboardingInput(
                        controller: _targetWeightController,
                        label: 'Target Weight (Optional)',
                        hintText: '70 kg',
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final weight = int.tryParse(value);
                            if (weight == null || weight < 30 || weight > 300) {
                              return 'Please enter a valid weight (30-300 kg)';
                            }
                          }
                          return null;
                        },
                        enabled: !isLoading,
                      ),
                      SizedBox(height: 32.h),
                      CircularButton(
                        label:
                            isLoading
                                ? 'Creating Account...'
                                : 'Create Account',
                        dark: false,
                        onTap:
                            isLoading ? () async {} : () async => _submitForm(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
