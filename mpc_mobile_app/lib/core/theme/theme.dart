import 'package:flutter/material.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get appTheme {
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
