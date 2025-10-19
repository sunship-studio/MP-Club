import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

// ignore: must_be_immutable
class OnboardingInput extends StatefulWidget {
  String label;
  String hintText;
  final String? Function(String?)? validator;
  TextEditingController? controller;
  bool password;
  bool enabled;
  OnboardingInput({
    super.key,
    this.validator,
    this.enabled = true,
    required this.label,
    required this.hintText,
    this.password = false,
    this.controller,
  });

  @override
  State<OnboardingInput> createState() => _OnboardingInputState();
}

class _OnboardingInputState extends State<OnboardingInput> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            letterSpacing: -0.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Container(
          margin: EdgeInsets.only(
            bottom: widget.validator != null ? 8.h : 16.h,
          ),
          child: TextFormField(
            enabled: widget.enabled,
            controller: widget.controller,
            validator: widget.validator,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.4,
            ),
            obscureText: widget.password ? obscureText : false,
            decoration: InputDecoration(
              suffixIcon:
                  widget.password
                      ? GestureDetector(
                        onTap: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        child: Icon(
                          obscureText ? Coolicons.hide : Coolicons.show,
                          color: AppColors.textSubColor,
                          size: 22,
                        ),
                      )
                      : null,
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[200]!.withValues(alpha: 0.05),
                  width: 1.2,
                  strokeAlign: -1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[200]!.withValues(alpha: 0.8),
                  width: 1.2,
                  strokeAlign: -1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey[200]!.withValues(alpha: 0.02),
                  width: 1.2,
                  strokeAlign: -1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.redColor,
                  width: 1.4,
                  strokeAlign: -1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.redColor,
                  width: 1.4,
                  strokeAlign: -1,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.textSubColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
