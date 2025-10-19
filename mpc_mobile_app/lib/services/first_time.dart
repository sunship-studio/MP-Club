import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeService {
  static const String _keyFirstTime = 'is_first_time';
  
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true; // Default true
  }
  
  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }
}