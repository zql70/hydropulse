import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

enum VolumeUnit { ml, oz }

class SettingsProvider extends ChangeNotifier {
  bool _remindersEnabled = true;
  VolumeUnit _unit = VolumeUnit.ml;
  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;
  UserProfile _profile = const UserProfile();

  bool get remindersEnabled => _remindersEnabled;
  VolumeUnit get unit => _unit;
  ThemeMode get themeMode => _themeMode;
  bool get initialized => _initialized;
  UserProfile get profile => _profile;

  String get unitLabel => _unit == VolumeUnit.ml ? 'ml' : 'oz';

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _remindersEnabled = prefs.getBool('reminders') ?? true;
    _unit = VolumeUnit.values[prefs.getInt('unit') ?? 0];
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _profile = UserProfile(
      name: prefs.getString('profile_name') ?? 'Alex Henderson',
      avatarUrl: prefs.getString('profile_avatarUrl') ?? '',
      height: prefs.getDouble('profile_height'),
      weight: prefs.getDouble('profile_weight'),
      dailyGoalMl: prefs.getInt('profile_dailyGoal') ?? 2850,
      location: prefs.getString('profile_location') ?? '旧金山',
    );
    _initialized = true;
    notifyListeners();
  }

  Future<void> _persistProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _profile.name);
    if (_profile.avatarUrl.isNotEmpty) {
      await prefs.setString('profile_avatarUrl', _profile.avatarUrl);
    } else {
      await prefs.remove('profile_avatarUrl');
    }
    if (_profile.height != null) {
      await prefs.setDouble('profile_height', _profile.height!);
    } else {
      await prefs.remove('profile_height');
    }
    if (_profile.weight != null) {
      await prefs.setDouble('profile_weight', _profile.weight!);
    } else {
      await prefs.remove('profile_weight');
    }
    await prefs.setInt('profile_dailyGoal', _profile.dailyGoalMl);
    await prefs.setString('profile_location', _profile.location);
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _profile = _profile.copyWith(name: name);
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateAvatar(String url) async {
    _profile = _profile.copyWith(avatarUrl: url);
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateHeight(double height) async {
    _profile = _profile.copyWith(height: height);
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateWeight(double weight) async {
    _profile = _profile.copyWith(weight: weight);
    await _persistProfile();
    notifyListeners();
  }

  Future<void> updateDailyGoal(int goal) async {
    _profile = _profile.copyWith(dailyGoalMl: goal);
    await _persistProfile();
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
