import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/add_subscriber.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';

class AddSubscriberScreen extends StatefulWidget {
  const AddSubscriberScreen({super.key});

  @override
  State<AddSubscriberScreen> createState() => _AddSubscriberScreenState();
}

class _AddSubscriberScreenState extends State<AddSubscriberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  double gap = 8;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddSubscribeCubit, AddSubscriberState>(
      listener: (context, state) {
        if (state is AddSubscriberSuccess) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscriber added successfully')),
          );
          context.go(RouteNames.onlineCoaching);
        } else if (state is AddSubscriberFailure) {
          // Show error message
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: BlocBuilder<AddSubscribeCubit, AddSubscriberState>(
        builder: (context, state) {
          if (state is AddSubscriberLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Subscriber Manually',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF-Pro',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: gap),

                    // First Name Input
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter first name',
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: gap),

                    // Last Name Input
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter last name',
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: gap),

                    // Age Input
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Enter age',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      showDoneButton: true, // Add this parameter
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 120) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitForm,
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 19, 157, 221),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                        ),
                        child: const Text(
                          'Add Subscriber',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'SF-Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    bool showDoneButton = false, // Add this parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF-Pro',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          textInputAction: textInputAction,
          onChanged: (value) {
            setState(() {});
          },
          onEditingComplete: () {
            // Move to next field or dismiss keyboard
            FocusScope.of(context).nextFocus();
          },
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'SF-Pro',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'SF-Pro',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 19, 157, 221),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'SF-Pro',
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // Show suffix icon only for age field
            suffixIcon:
                showDoneButton && controller.text.isNotEmpty
                    ? IconButton(
                      padding: const EdgeInsets.all(12),
                      icon: const Icon(
                        Icons.check_circle,
                        color: Color.fromARGB(255, 19, 157, 221),
                        size: 24,
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get the values
      final email = _emailController.text;
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final age = int.parse(_ageController.text);

      // TODO: Send data to API or handle submission
      print('Submitting:');
      print('Email: $email');
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Age: $age');

      context.read<AddSubscribeCubit>().addSubscriber(
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
      );
    }
  }
}
