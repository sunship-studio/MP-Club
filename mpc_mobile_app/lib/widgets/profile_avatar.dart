import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  ProfileAvatar({super.key, this.radius = 20});
  double radius;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle avatar tap if needed
      },
      onTapDown: (details) => setState(() => _isPressed = true),
      onTapUp: (details) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),

        child: CircleAvatar(
          radius: widget.radius,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ),
    );
  }
}
