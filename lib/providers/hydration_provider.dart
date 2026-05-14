import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drink_record.dart';

class HydrationProvider extends ChangeNotifier {
  static const _storageKey = 'drink_records';
  static const _demoSeededKey = 'demo_seeded';
  static const _customVolumesKey = 'custom_volumes';

  int _dailyGoal = 2000;
  final List<DrinkRecord> _records = [];
  int _selectedVolume = 200;
  DrinkType _selectedType = DrinkType.water;
  final List<int> _customVolumes = [];

  int get dailyGoal => _dailyGoal;
  List<DrinkRecord> get records => List.unmodifiable(_records);
  int get selectedVolume => _selectedVolume;
  String get selectedVolumeLabel => '${_selectedVolume}ml';
  DrinkType get selectedType => _selectedType;
  List<int> get customVolumes => List.unmodifiable(_customVolumes);

  List<DrinkRecord> get todayRecords {
    final today = _records.where((r) => r.timestamp.isAfter(_todayStart)).toList();
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today;
  }

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<DrinkRecord> get _todayRecords =>
      _records.where((r) => r.timestamp.isAfter(_todayStart)).toList();

  int get currentIntake =>
      _todayRecords.fold(0, (sum, r) => sum + r.volume);

  double get effectiveIntake =>
      _todayRecords.fold(0.0, (sum, r) => sum + r.effectiveVolume);

  double get dailyProgress {
    if (_dailyGoal == 0) return 0;
    return (currentIntake / _dailyGoal).clamp(0, 1);
  }

  double get dailyProgressPercent => dailyProgress * 100;

  int get drinkScore {
    final pct = dailyProgressPercent;
    if (pct >= 100) return 100;
    if (pct >= 85) return 88;
    if (pct >= 70) return 75;
    if (pct >= 50) return 60;
    return 40;
  }

  void setDailyGoal(int goal) {
    if (goal == _dailyGoal) return;
    _dailyGoal = goal;
    notifyListeners();
  }

  void selectVolume(int volume) {
    _selectedVolume = volume;
    notifyListeners();
  }

  void selectType(DrinkType type) {
    _selectedType = type;
    notifyListeners();
  }

  static const _defaultVolumes = [500, 300, 200];

  void addCustomVolume(int volume) {
    if (_customVolumes.contains(volume) || _defaultVolumes.contains(volume)) return;
    _customVolumes.add(volume);
    _customVolumes.sort((a, b) => b.compareTo(a));
    _persistCustomVolumes();
    notifyListeners();
  }

  void removeCustomVolume(int volume) {
    _customVolumes.remove(volume);
    _persistCustomVolumes();
    if (_selectedVolume == volume) {
      _selectedVolume = 200;
    }
    notifyListeners();
  }

  void addDrink({DrinkType? type, int? volume}) {
    final v = volume ?? _selectedVolume;
    final t = type ?? _selectedType;
    _records.add(DrinkRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: t,
      volume: v,
      timestamp: DateTime.now(),
    ));
    _persistRecords();
    notifyListeners();
  }

  void removeRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    _persistRecords();
    notifyListeners();
  }

  /// Returns merged hourly distribution: 0-8 combined, then 9..23 individually
  /// Keys are bucket start hours: 0, 9, 10, 11, ..., 23
  List<MapEntry<int, int>> getHourlyDistribution() {
    final dist = <int, int>{0: 0};
    for (var h = 9; h <= 23; h++) {
      dist[h] = 0;
    }

    for (final r in _todayRecords) {
      final h = r.timestamp.hour;
      if (h <= 8) {
        dist[0] = (dist[0] ?? 0) + r.volume;
      } else {
        dist[h] = (dist[h] ?? 0) + r.volume;
      }
    }
    return dist.entries.toList();
  }

  /// Returns day → total ml for a given month
  Map<int, int> getDailyTotals(int year, int month) {
    final map = <int, int>{};
    for (final r in _records) {
      if (r.timestamp.year == year && r.timestamp.month == month) {
        final d = r.timestamp.day;
        map[d] = (map[d] ?? 0) + r.volume;
      }
    }
    return map;
  }

  /// Returns [Mon..Sun] daily total volume for current week (as fraction of goal)
  List<double> getWeeklyData() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final totals = <double>[0, 0, 0, 0, 0, 0, 0];

    for (final r in _records) {
      if (r.timestamp.isAfter(weekStart)) {
        final dayIdx = r.timestamp.weekday - 1;
        if (dayIdx >= 0 && dayIdx < 7) {
          totals[dayIdx] += r.volume / _dailyGoal;
        }
      }
    }

    // Fall back to demo data only if no records exist at all
    if (totals.every((t) => t == 0) && _records.isEmpty) {
      return [0.5, 0.4, 0.7, 0.6, 0.9, 0.8, 0.35];
    }
    return totals.map((t) => t < 0 ? 0.0 : t).toList();
  }

  /// Returns beverage type breakdown for today: {type: percentage}
  Map<DrinkType, double> getBeverageBreakdown() {
    final total = currentIntake;
    if (total == 0) {
      return {for (var t in DrinkType.values) t: 0.0};
    }
    final map = <DrinkType, int>{};
    for (final r in _todayRecords) {
      map[r.type] = (map[r.type] ?? 0) + r.volume;
    }
    return map.map((k, v) => MapEntry(k, v / total));
  }

  // ---- Persistence ----

  Future<void> init() async {
    await _loadRecords();
    await _loadCustomVolumes();
    if (_customVolumes.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final wasSeeded = prefs.getBool('custom_volumes_seeded') ?? false;
      if (!wasSeeded) {
        _customVolumes.addAll([450, 400, 350, 250, 150, 100, 50]);
        await _persistCustomVolumes();
        await prefs.setBool('custom_volumes_seeded', true);
      }
    }
    if (_records.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final seeded = prefs.getBool(_demoSeededKey) ?? false;
      if (!seeded) {
        seedDemoData();
        await prefs.setBool(_demoSeededKey, true);
      }
    }
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _records.clear();
      _records.addAll(list.map((e) => DrinkRecord.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Corrupted data — reset
      await prefs.remove(_storageKey);
    }
  }

  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  Future<void> _loadCustomVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customVolumesKey);
    if (raw == null) return;
    try {
      _customVolumes.clear();
      _customVolumes.addAll((jsonDecode(raw) as List<dynamic>).cast<int>());
    } catch (_) {
      await prefs.remove(_customVolumesKey);
    }
  }

  Future<void> _persistCustomVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customVolumesKey, jsonEncode(_customVolumes));
  }

  void seedDemoData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _records.addAll([
      DrinkRecord(id: 'd1', type: DrinkType.water, volume: 300, timestamp: today.add(const Duration(hours: 8, minutes: 30))),
      DrinkRecord(id: 'd2', type: DrinkType.water, volume: 200, timestamp: today.add(const Duration(hours: 10, minutes: 15))),
      DrinkRecord(id: 'd3', type: DrinkType.coffee, volume: 250, timestamp: today.add(const Duration(hours: 11, minutes: 0))),
      DrinkRecord(id: 'd4', type: DrinkType.water, volume: 300, timestamp: today.add(const Duration(hours: 13, minutes: 45))),
      DrinkRecord(id: 'd5', type: DrinkType.water, volume: 250, timestamp: today.add(const Duration(hours: 15, minutes: 20))),
    ]);
    _persistRecords();
    notifyListeners();
  }
}
