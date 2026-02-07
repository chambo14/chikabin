import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppThemeMode {
  light('Clair'),
  dark('Sombre'),
  system('Système');

  final String label;
  const AppThemeMode(this.label);
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier() : super(AppThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = Hive.box('settings');
    final savedTheme = box.get(_themeKey, defaultValue: 'light');

    state = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
      orElse: () => AppThemeMode.light,
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final box = Hive.box('settings');
    await box.put(_themeKey, mode.name);
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(
      (ref) => ThemeNotifier(),
);