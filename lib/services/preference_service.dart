import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyUserName = 'user_name';
  static const String _keyDailyReminder = 'daily_reminder';

  static PreferenceService? _instance;
  final SharedPreferences _prefs;

  PreferenceService._(this._prefs);

  static Future<PreferenceService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = PreferenceService._(prefs);
    }
    return _instance!;
  }

  ThemeMode getThemeMode() {
    final mode = _prefs.getString(_keyThemeMode);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _prefs.setString(_keyThemeMode, value);
  }

  String getUserName() {
    return _prefs.getString(_keyUserName) ?? 'Chiến binh kỷ luật';
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  bool getDailyReminderEnabled() {
    return _prefs.getBool(_keyDailyReminder) ?? true;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    await _prefs.setBool(_keyDailyReminder, enabled);
  }
}

