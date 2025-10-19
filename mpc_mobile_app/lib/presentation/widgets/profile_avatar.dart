import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileAvatar extends StatefulWidget {
  ProfileAvatar({super.key, this.radius = 20, this.onTap});
  double radius;
  Function()? onTap;


  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return CircleAvatar(
        radius: widget.radius.w,
        backgroundImage: AssetImage('assets/images/avatar.png'),
      );
    }
    return GestureDetector(
      onTap: () {
       widget.onTap!();
      },
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapUp: (details) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),

        child: CircleAvatar(
          radius: widget.radius.w,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ),
    );
  }
}
