import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/models/User.dart';

class ProfileAvatar extends StatefulWidget {
  ProfileAvatar({super.key, this.radius = 20, this.onTap, required this.user});
  double radius;
  User user;
  Function()? onTap;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine the image provider based on profilePictureUrl
    ImageProvider imageProvider;
    if (widget.user.profilePictureUrl != null &&
        widget.user.profilePictureUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.user.profilePictureUrl!);
    } else {
      imageProvider = AssetImage('assets/default_avatar.png');
    }

    if (widget.onTap == null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: imageProvider,
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
          radius: widget.radius,
          backgroundImage: imageProvider,
        ),
      ),
    );
  }
}
