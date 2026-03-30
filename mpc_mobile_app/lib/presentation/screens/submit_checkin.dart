import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/check_in.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/multi_image_picker.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/presentation/widgets/header.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';

class SubmitCheckInScreen extends StatefulWidget {
  const SubmitCheckInScreen({super.key});

  @override
  State<SubmitCheckInScreen> createState() => _SubmitCheckInScreenState();
}

class _SubmitCheckInScreenState extends State<SubmitCheckInScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showNavBar) navBarKey.currentState?.turnOffNavBar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!showNavBar) {
        navBarKey.currentState?.turnOnNavBar();
      }
    });
    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _wellbeingController = TextEditingController();
  final TextEditingController _biggestWinController = TextEditingController();
  final TextEditingController _strugglesController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.redColor),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    int maxLines = 3,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          width: 1,
          color: AppColors.greyTextColor.withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12.w),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.greyTextColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: BlocListener<CheckInCubit, CheckInState>(
        listener: (context, state) {
          if (state is CheckInSuccess) {
            SnackBarService.show(
              context: context,
              message: "Check-In submitted successfully!",
            );

            context.read<AuthCubit>().loadUser();
            context.pop();
          } else if (state is CheckInError) {
            SnackBarService.show(
              context: context,
              message: state.message,
              isError: true,
            );
          }
        },
        child: BlocBuilder<CheckInCubit, CheckInState>(
          builder: (context, state) {
            if (state is CheckInLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.blueColor),
              );
            }

            final imagePaths = state is CheckInImagesPicked
                ? state.imagePaths
                : context.read<CheckInCubit>().imagePaths;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  MpcHeader(
                    onBack: () => {context.pop()},
                    label: "Check-in Form",
                    backgroundColor: AppColors.darkScaffoldColor,
                    suffix: Icon(
                      Coolicons.info_circle_outline,
                      size: 24.w,
                      color: Colors.white,
                    ),
                    onSuffixTap: () => context.push('/check_in/info'),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date row
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Gap(8.h),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(
                                          () => _selectedDate = date);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: AppColors.greyTextColor
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      DateFormat('d MMM, yyyy')
                                          .format(_selectedDate),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Gap(12.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: _selectedTime,
                                    );
                                    if (time != null) {
                                      setState(
                                          () => _selectedTime = time);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.h, horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: AppColors.greyTextColor
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap(20.h),

                          // Weight
                          _buildLabel("Weight Update/kg", required: true),
                          Gap(8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                width: 1,
                                color: AppColors.greyTextColor
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () =>
                                  FocusScope.of(context).unfocus(),
                              controller: _weightController,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12.w),
                                hintText: "0",
                                hintStyle: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyTextColor,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Gap(20.h),

                          // Wellbeing
                          _buildLabel(
                              "How do you feel/overall well being?",
                              required: true),
                          Gap(8.h),
                          _buildTextField(
                              controller: _wellbeingController),
                          Gap(20.h),

                          // Photos
                          Text(
                            "Current photos (front, back, side)",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Gap(8.h),
                          MultiImagePicker(imagePaths: imagePaths),
                          Gap(20.h),

                          // Biggest win
                          _buildLabel("Biggest win from this week",
                              required: true),
                          Gap(8.h),
                          _buildTextField(
                              controller: _biggestWinController),
                          Gap(20.h),

                          // Struggles
                          _buildLabel(
                              "What did you struggle with most this week?",
                              required: true),
                          Gap(8.h),
                          _buildTextField(
                              controller: _strugglesController),
                          Gap(20.h),

                          // Questions
                          _buildLabel("Do you have any questions?",
                              required: true),
                          Gap(8.h),
                          _buildTextField(
                              controller: _questionsController),
                          Gap(24.h),

                          // Submit
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, authState) {
                              authState as Authenticated;
                              return CircularButton(
                                label: "Submit Check-In",
                                dark: false,
                                onTap: () async {
                                  // Validate required fields
                                  if (_wellbeingController
                                      .text.isEmpty) {
                                    SnackBarService.show(
                                      context: context,
                                      message:
                                          "Please fill in wellbeing field",
                                      isError: true,
                                    );
                                    return;
                                  }
                                  if (_biggestWinController
                                      .text.isEmpty) {
                                    SnackBarService.show(
                                      context: context,
                                      message:
                                          "Please fill in biggest win field",
                                      isError: true,
                                    );
                                    return;
                                  }
                                  if (_strugglesController
                                      .text.isEmpty) {
                                    SnackBarService.show(
                                      context: context,
                                      message:
                                          "Please fill in struggles field",
                                      isError: true,
                                    );
                                    return;
                                  }
                                  if (_questionsController
                                      .text.isEmpty) {
                                    SnackBarService.show(
                                      context: context,
                                      message:
                                          "Please fill in questions field",
                                      isError: true,
                                    );
                                    return;
                                  }

                                  context
                                      .read<CheckInCubit>()
                                      .submitCheckIn(
                                        userId: authState.user.id,
                                        weight:
                                            _weightController.text,
                                        wellbeing:
                                            _wellbeingController.text,
                                        biggestWin:
                                            _biggestWinController
                                                .text,
                                        struggles:
                                            _strugglesController
                                                .text,
                                        questions:
                                            _questionsController
                                                .text,
                                      );
                                },
                              );
                            },
                          ),
                          Gap(32.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
