import 'package:flutter/material.dart';

double bottomPadding(BuildContext context) {
  return MediaQuery.of(context).viewPadding.bottom;
}

double topPadding(BuildContext context) {
  return MediaQuery.of(context).viewPadding.top;
}

double horizontalPadding = 25.0;
double verticalPadding = 24.0;

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Scale font based on screen width (375 = iPhone SE baseline)
  static double fontSize(BuildContext context, double size) {
    return size * (width(context) / 350);
  }

  // Scale spacing/padding
  static double spacing(BuildContext context, double size) {
    return size * (width(context) / 350);
  }
}
