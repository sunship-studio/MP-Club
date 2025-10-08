import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class CircularButton extends StatefulWidget {
  CircularButton({
    super.key,
    this.icon,
    required this.label,
    required this.dark,
    required this.onTap,
    this.color,
    this.textColor,
    this.borderColor,
  });
  Color? color;
  Color? borderColor;
  Color? textColor;
  String label;
  Widget? icon;
  bool dark;
  Future<void> Function() onTap;
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
        });
        await widget.onTap();
        print("Tapped ${widget.label} button");
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
        duration: const Duration(milliseconds: 50),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color:
                widget.color ??
                (widget.dark
                    ? const Color.fromARGB(255, 101, 116, 150)
                    : Colors.white),
            borderRadius: BorderRadius.circular(100),
            border:
                widget.borderColor == null
                    ? Border.all(
                      color:
                          widget.dark
                              ? Colors.grey[200]!.withValues(alpha: 0.07)
                              : Colors.grey[200]!,
                      width: 1.5,
                      strokeAlign: -1,
                    )
                    : Border.all(
                      color: widget.borderColor!,
                      width: 2,
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
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[widget.icon!, Gap(8.w)],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color:
                              widget.textColor ??
                              (widget.dark
                                  ? AppColors.lightTextColor
                                  : AppColors.darkTextColor),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
