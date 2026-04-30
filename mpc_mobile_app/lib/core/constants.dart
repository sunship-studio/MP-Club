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
  // Legal URLs
  static const String termsOfUseUrl =
      'https://www.midlandsperformanceclub.ie/terms-and-conditions';
  static const String privacyPolicyUrl =
      'https://gist.github.com/kamryy/418f8f96a1764828d36e2b1ac6f6fc50';

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

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

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
