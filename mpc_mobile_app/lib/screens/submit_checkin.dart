import 'package:coolicons/coolicons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:mpc_mobile_app/widgets/header.dart';
import 'package:mpc_mobile_app/widgets/check_in/sheets/browse_file.dart';

class SubmitCheckIn extends StatelessWidget {
  const SubmitCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MpcHeader(
            label: "SUBMIT CHECK-IN",
            backgroundColor: AppColors.darkScaffoldColor,
            suffix: Icon(
              Coolicons.info_circle_outline,
              size: 24.w,
              color: Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 24.h,
              horizontal: horizontalPadding,
            ),
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
            child: Column(
              children: [
                Text(
                  "Weight Update/lbs",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyTextColor.withAlpha(150),
                  ),
                ),

                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 58.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: "0",
                    hintStyle: TextStyle(
                      fontSize: 58.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCardColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 2.h,
                  color: AppColors.darkCardColor,
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 24.h,
                horizontal: horizontalPadding,
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notes / Mood (Optional)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkTextColor.withValues(alpha: 0.8),
                        ),
                      ),
                      Gap(4.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            width: 1,
                            color: AppColors.greyTextColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: TextField(
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkTextColor,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.w),
                            hintText: "Placeholder",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.greyTextColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upload Photo",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkTextColor.withValues(alpha: 0.8),
                        ),
                      ),
                      Gap(4.h),
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(8.r),
                          color: AppColors.greyTextColor.withValues(alpha: 0.4),
                          strokeWidth: 1,

                          dashPattern: [6, 6],
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 26.h,
                            horizontal: 12.w,
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                "assets/images/photo.svg",
                                width: 26,
                              ),
                              Gap(8.h),
                              Text(
                                "Progress Photo Upload",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Gap(4.h),
                              Text(
                                "Accepted formats: PNG, JPG, PDF",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.darkScaffoldColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              Gap(16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TakePhotoButton(),
                                  Gap(8.w),
                                  BrowseGalleryButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  CircularButton(
                    label: "Submit Check-In",
                    dark: false,
                    onTap: () async {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseGalleryButton extends StatefulWidget {
  const BrowseGalleryButton({super.key});

  @override
  State<BrowseGalleryButton> createState() => _BrowseGalleryButtonState();
}

class _BrowseGalleryButtonState extends State<BrowseGalleryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {showBrowseFileSheet(context)},
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

      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 75),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: AppColors.darkScaffoldColor.withValues(alpha: 0.1),
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            "Browse Gallery",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

class TakePhotoButton extends StatefulWidget {
  const TakePhotoButton({super.key});

  @override
  State<TakePhotoButton> createState() => _TakePhotoButtonState();
}

class _TakePhotoButtonState extends State<TakePhotoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
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
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 75),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.darkScaffoldColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            "Take a Photo",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
