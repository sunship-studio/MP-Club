import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/data/models/user.dart';

class ProfileAvatar extends StatefulWidget {
  ProfileAvatar({super.key, this.radius = 20, this.onTap, this.user});
  double radius;
  User? user;
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
        backgroundImage:
            widget.user != null
                ? widget.user!.profilePictureUrl == null
                    ? AssetImage('assets/images/default_avatar.png')
                    : NetworkImage(widget.user!.profilePictureUrl!)
                : AssetImage('assets/images/avatar.png') as ImageProvider,
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
          backgroundImage:
              widget.user != null
                  ? widget.user!.profilePictureUrl == null
                      ? AssetImage('assets/images/default_avatar.png')
                          as ImageProvider
                      : NetworkImage(widget.user!.profilePictureUrl!)
                  : AssetImage('assets/images/avatar.png') as ImageProvider,
        ),
      ),
    );
  }
}
