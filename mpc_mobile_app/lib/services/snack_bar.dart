import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class SnackBarService {
  static show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isFloating = false,
    bool isNavBar = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      isError
          ? SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            padding: EdgeInsets.only(
              top: 16.0.h,
              bottom:
                  isNavBar
                      ? bottomPadding(context) + 40.0.h
                      : bottomPadding(context),
              left: horizontalPadding.w,
              right: horizontalPadding.w,
            ),
            margin:
                isFloating
                    ? EdgeInsets.only(
                      bottom:
                          isNavBar
                              ? bottomPadding(context) + 50.0.h
                              : bottomPadding(context),
                    )
                    : null,
            behavior:
                isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            backgroundColor: AppColors.redColor,
          )
          : SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.only(
              top: 16.0.h,

              bottom:
                  isFloating
                      ? 16.0.h
                      : isNavBar
                      ? bottomPadding(context) + 40.0.h
                      : bottomPadding(context),
              left: horizontalPadding.w,
              right: horizontalPadding.w,
            ),
            backgroundColor: AppColors.blueColor,
            behavior:
                isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
            content: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
    );
  }
}
