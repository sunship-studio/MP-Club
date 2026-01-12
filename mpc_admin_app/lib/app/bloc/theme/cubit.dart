import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mpc_admin_app/app/bloc/theme/state.dart';

/// Manages theme state with persistence
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeModeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeLightState()) {
    _loadThemePreference();
  }

  /// Load saved theme preference on startup
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);

      if (savedMode == 'dark') {
        emit(const ThemeDarkState());
      } else if (savedMode == 'light') {
        emit(const ThemeLightState());
      } else if (savedMode == 'system') {
        emit(const ThemeSystemState());
      } else {
        // Default to light mode if no saved preference
        emit(const ThemeLightState());
      }
    } catch (e) {
      // If loading fails, default to light mode
      debugPrint('Failed to load theme preference: $e');
      emit(const ThemeLightState());
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    if (state is ThemeLightState || state is ThemeSystemState) {
      await setDarkTheme();
    } else {
      await setLightTheme();
    }
  }

  /// Set light theme explicitly
  Future<void> setLightTheme() async {
    emit(const ThemeLightState());
    await _saveThemePreference('light');
  }

  /// Set dark theme explicitly
  Future<void> setDarkTheme() async {
    emit(const ThemeDarkState());
    await _saveThemePreference('dark');
  }

  /// Use system theme (follows device settings)
  Future<void> setSystemTheme() async {
    emit(const ThemeSystemState());
    await _saveThemePreference('system');
  }

  /// Save theme preference to persistent storage
  Future<void> _saveThemePreference(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode);
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Get current ThemeMode for MaterialApp
  ThemeMode get themeMode {
    if (state is ThemeDarkState) return ThemeMode.dark;
    if (state is ThemeLightState) return ThemeMode.light;
    return ThemeMode.system;
  }
}
