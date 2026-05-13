import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VolumeUnit { ml, oz }

class SettingsProvider extends ChangeNotifier {
  bool _remindersEnabled = true;
  VolumeUnit _unit = VolumeUnit.ml;
  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;

  bool get remindersEnabled => _remindersEnabled;
  VolumeUnit get unit => _unit;
  ThemeMode get themeMode => _themeMode;
  bool get initialized => _initialized;

  String get unitLabel => _unit == VolumeUnit.ml ? 'ml' : 'oz';

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _remindersEnabled = prefs.getBool('reminders') ?? true;
    _unit = VolumeUnit.values[prefs.getInt('unit') ?? 0];
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleReminders() async {
    _remindersEnabled = !_remindersEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders', _remindersEnabled);
    notifyListeners();
  }

  Future<void> setUnit(VolumeUnit unit) async {
    _unit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unit', unit.index);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }
}
