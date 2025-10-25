import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
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
    Widget avatar;

    if (widget.user?.profilePictureUrl != null) {
      avatar = CachedNetworkImage(
        imageUrl: widget.user!.profilePictureUrl!,
        imageBuilder:
            (context, imageProvider) => CircleAvatar(
              radius: widget.radius.w,
              backgroundImage: imageProvider,
            ),
        placeholder:
            (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[100]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(10.w),
              width: widget.radius.w * 2,
              height: widget.radius.w * 2,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 1.5.w,
                color: AppColors.blueColor,
              ),
            ),

        errorWidget:
            (context, url, error) => CircleAvatar(
              radius: widget.radius.w,
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
      );
    } else {
      avatar = CircleAvatar(
        radius: widget.radius.w,
        backgroundImage: AssetImage(
          widget.user != null
              ? 'assets/images/default_avatar.png'
              : 'assets/images/avatar.png',
        ),
      );
    }

    if (widget.onTap == null) return avatar;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: avatar,
      ),
    );
  }
}
