import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class CircularButton extends StatefulWidget {
  CircularButton({
    super.key,
    required this.label,
    required this.dark,
    this.onTap,
  });
  String label;
  bool dark;
  Function()? onTap;
  @override
  State<CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
          widget.onTap!();
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapUp: (details) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding:  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.dark ? AppColors.darkScaffoldColor : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color:
                  widget.dark
                      ? Colors.grey[200]!.withValues(alpha: 0.07)
                      : Colors.grey[200]!,
              width: 1.5,
              strokeAlign: -1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.0),
                blurRadius: _isPressed ? 4 : 8,
                offset: Offset(0, _isPressed ? 1 : 2),
              ),
            ],
          ),
          child:
              _isLoading
                  ? Image.asset('assets/images/loading.gif', height: 18)
                  : Text(
                    widget.label,
                    style: TextStyle(
                      color:
                          widget.dark
                              ? AppColors.lightTextColor
                              : AppColors.darkTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
        ),
      ),
    );
  }
}
