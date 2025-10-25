import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/services/image.dart';

ImageService imageService = ImageService();

Future<File?> showBrowseFileSheet(
  BuildContext context, {
  bool showNavBarAfter = false,
  String title = 'BROWSE FILE',
  Function? setFile,
}) async {
  final completer = Completer<File?>();

  showModalBottomSheet<File?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder:
        (sheetContext) => Wrap(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 8.h,
                left: horizontalPadding.w,

                bottom: bottomPadding(context) + 16.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightScaffoldColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          letterSpacing: -0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding.w,
                            vertical: 8.h,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 24.w,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Gap(8.h),
                  // Container(
                  //   height: 100.w,

                  //   child: ListView.builder(
                  //     itemCount: 6,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, index) {
                  //       if (index == 0) {
                  //         return
                  //       } else {
                  //         return RecentPhotoButton();
                  //       }
                  //     },
                  //   ),
                  // ),
                  // SizedBox(height: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TakePhotoButton(
                        setSelectedFile: (file) {
                          completer.complete(file);
                        },
                      ),
                      SizedBox(height: 12.h),
                      ChooseFromGalleryButton(
                        setSelectedFile: (value) {
                          completer.complete(value);
                          sheetContext.pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
  );

  final result = await completer.future;
  return result;
}

class TakePhotoButton extends StatefulWidget {
  TakePhotoButton({super.key, required this.setSelectedFile});
  Function setSelectedFile;

  @override
  State<TakePhotoButton> createState() => _TakePhotoButtonState();
}

class _TakePhotoButtonState extends State<TakePhotoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () async {
        final file = await imageService.pickImageFromCamera();
        await Future.delayed(Duration(milliseconds: 500));
        print("TAKE PHOTO FILE: $file");
        if (file != null) {
          widget.setSelectedFile(file);
        }
      },

      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 100.w,
          height: 100.w,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.darkScaffoldColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset("assets/images/camera-plus.svg"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentPhotoButton extends StatefulWidget {
  const RecentPhotoButton({super.key});

  @override
  State<RecentPhotoButton> createState() => _RecentPhotoButtonState();
}

class _RecentPhotoButtonState extends State<RecentPhotoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () async {},

      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/checkin.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          width: 100.w,
          height: 100.w,
        ),
      ),
    );
  }
}

class ChooseFromGalleryButton extends StatefulWidget {
  ChooseFromGalleryButton({super.key, required this.setSelectedFile});
  Function setSelectedFile;

  @override
  State<ChooseFromGalleryButton> createState() =>
      _ChooseFromGalleryButtonState();
}

class _ChooseFromGalleryButtonState extends State<ChooseFromGalleryButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () async {
        final file = await imageService.pickImageFromGallery();
        if (file != null) {
          widget.setSelectedFile(file);
        }
      },

      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/images/photo-filled.svg",
                width: 24.w,
                height: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
