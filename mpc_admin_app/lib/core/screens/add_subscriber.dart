import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/add_subscriber.dart';
import 'package:mpc_admin_app/core/widgets/modern/index.dart';

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
          context.push('/waiting-list');
        } else if (state is AddSubscriberFailure) {
          // Show error message
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: BlocBuilder<AddSubscribeCubit, AddSubscriberState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              // This makes the content scrollable when keyboard appears
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 16,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    16, // Add keyboard padding
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).viewInsets.bottom -
                      100, // Account for header
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Subscriber Manually',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
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
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.next,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputAction: TextInputAction.done,
                          showDoneButton: true,
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

                        // Submit Button
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: ModernButton(
                              onPressed: _submitForm,
                              label: 'Add Subscriber',
                              icon: Icons.add,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF-Pro',
          ),
        ),
        const SizedBox(height: 8),
        ModernTextInput(
          validator: validator,
          controller: controller,
          hintText: hint,
          onChanged: (value) {
            setState(() {});
          },
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
      print('Age: ${_ageController.text}');
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
