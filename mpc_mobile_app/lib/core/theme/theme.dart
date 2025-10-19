import 'package:flutter/material.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.lightScaffoldColor,
      cardColor: AppColors.darkCardColor,

      fontFamily: "Inter",

      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: AppColors.blueColor,
      ),
    );
  }
}
