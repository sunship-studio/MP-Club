import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';

class MpcIconButton extends StatefulWidget {
  MpcIconButton({
    super.key,
    this.size = 24,
    this.padding = 12,
    this.onTap,
    required this.icon,
  });
  double size;
  double padding;
  Function()? onTap;
  IconData icon;
  @override
  State<MpcIconButton> createState() => _MpcIconButtonState();
}

class _MpcIconButtonState extends State<MpcIconButton> {
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
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: EdgeInsets.all(widget.padding.w),
        child: AnimatedScale(
          scale: _isPressed ? 0.85 : 1.0,
          duration: Duration(milliseconds: 100),
          child: Icon(widget.icon, size: widget.size, color: Colors.white),
        ),
      ),
    );
  }
}
