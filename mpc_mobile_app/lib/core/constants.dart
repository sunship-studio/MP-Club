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

class Constants {
  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static const List<String> shortMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  static const List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  static String? repeatPasswordValidator(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}
