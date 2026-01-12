import 'package:equatable/equatable.dart';

/// Base theme state
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Light theme state
class ThemeLightState extends ThemeState {
  const ThemeLightState();
}

/// Dark theme state
class ThemeDarkState extends ThemeState {
  const ThemeDarkState();
}

/// System default theme state (follows device settings)
class ThemeSystemState extends ThemeState {
  const ThemeSystemState();
}
