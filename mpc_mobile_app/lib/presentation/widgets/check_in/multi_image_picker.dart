import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/check_in.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/sheets/browse_file.dart';

class MultiImagePicker extends StatelessWidget {
  const MultiImagePicker({super.key, required this.imagePaths});
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ...List.generate(imagePaths.length, (index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(imagePaths[index]),
                  width: 90.w,
                  height: 90.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () =>
                      context.read<CheckInCubit>().removeImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        GestureDetector(
          onTap: () async {
            final file = await showBrowseFileSheet(
              context,
              showNavBarAfter: false,
            );
            if (file != null && context.mounted) {
              context.read<CheckInCubit>().pickImage(file.path);
            }
          },
          child: Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.greyTextColor.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.add,
              size: 32.w,
              color: AppColors.greyTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
