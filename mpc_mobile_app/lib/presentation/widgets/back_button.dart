import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';

class MpcBackButton extends StatefulWidget {
  MpcBackButton({super.key, this.onTap, this.color = Colors.white});
  Function()? onTap;
  Color? color;

  @override
  State<MpcBackButton> createState() => _MpcBackButtonState();
}

class _MpcBackButtonState extends State<MpcBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // Your action here
      },
      onTap:
          () => {
            if (widget.onTap != null) {widget.onTap!()} else {context.pop()},
          },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.w,
          vertical: 16.h,
        ),
        child: AnimatedScale(
          scale: _isPressed ? 0.85 : 1.0,
          duration: Duration(milliseconds: 100),
          child: Icon(
            Coolicons.chevron_big_left,
            size: 24.w,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
