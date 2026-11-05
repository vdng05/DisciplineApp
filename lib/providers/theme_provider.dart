import 'package:flutter/material.dart';
import '../services/preference_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferenceService _preferenceService;
  late ThemeMode _themeMode;

  ThemeProvider(this._preferenceService) {
    _themeMode = _preferenceService.getThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _preferenceService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

