import 'package:flutter/foundation.dart';
import '../models/drink_record.dart';

class HydrationProvider extends ChangeNotifier {
  final int dailyGoal = 2000;
  final double targetLiters = 2.85;

  final List<DrinkRecord> _records = [];
  String _selectedVolume = '200';
  DrinkType _selectedType = DrinkType.water;

  List<DrinkRecord> get records => List.unmodifiable(_records);
  String get selectedVolume => _selectedVolume;
  DrinkType get selectedType => _selectedType;

  int get currentIntake =>
      _records.fold(0, (sum, r) => sum + r.volume);

  double get effectiveIntake =>
      _records.fold(0.0, (sum, r) => sum + r.effectiveVolume);

  double get dailyProgress {
    if (dailyGoal == 0) return 0;
    return currentIntake / dailyGoal;
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

  void selectVolume(String volume) {
    _selectedVolume = volume;
    notifyListeners();
  }

  void selectType(DrinkType type) {
    _selectedType = type;
    notifyListeners();
  }

  void addDrink({DrinkType? type, int? volume}) {
    final v = volume ?? int.tryParse(_selectedVolume) ?? 200;
    final t = type ?? _selectedType;
    _records.add(DrinkRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: t,
      volume: v,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void removeRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Returns hourly distribution [8, 12, 16, 20] hour → volume
  List<MapEntry<int, int>> getHourlyDistribution() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final hours = [8, 10, 12, 14, 16, 18, 20, 22];
    final dist = <int, int>{for (var h in hours) h: 0};

    for (final r in _records) {
      if (r.timestamp.isAfter(todayStart)) {
        final h = r.timestamp.hour;
        final bucket = hours.where((bh) => bh >= h).firstOrNull ?? hours.last;
        dist[bucket] = (dist[bucket] ?? 0) + r.volume;
      }
    }
    return dist.entries.toList();
  }

  /// Returns [Mon..Sun] daily total volume for current week
  List<double> getWeeklyData() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final totals = <double>[0.5, 0.4, 0.7, 0.6, 0.9, 0.8, 0.35]; // demo data

    for (final r in _records) {
      if (r.timestamp.isAfter(weekStart)) {
        final dayIdx = r.timestamp.weekday - 1;
        if (dayIdx >= 0 && dayIdx < 7) {
          totals[dayIdx] += r.volume / 2000;
        }
      }
    }
    return totals.map((t) => t < 0 ? 0.0 : (t > 1 ? 1.0 : t)).toList();
  }

  /// Returns beverage type breakdown: {type: percentage}
  Map<DrinkType, double> getBeverageBreakdown() {
    final total = currentIntake;
    if (total == 0) {
      return {for (var t in DrinkType.values) t: 0.0};
    }
    final map = <DrinkType, int>{};
    for (final r in _records) {
      map[r.type] = (map[r.type] ?? 0) + r.volume;
    }
    return map.map((k, v) => MapEntry(k, v / total));
  }

  void seedDemoData() {
    if (_records.isNotEmpty) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _records.addAll([
      DrinkRecord(id: 'd1', type: DrinkType.water, volume: 300, timestamp: today.add(const Duration(hours: 8, minutes: 30))),
      DrinkRecord(id: 'd2', type: DrinkType.water, volume: 200, timestamp: today.add(const Duration(hours: 10, minutes: 15))),
      DrinkRecord(id: 'd3', type: DrinkType.coffee, volume: 250, timestamp: today.add(const Duration(hours: 11, minutes: 0))),
      DrinkRecord(id: 'd4', type: DrinkType.water, volume: 300, timestamp: today.add(const Duration(hours: 13, minutes: 45))),
      DrinkRecord(id: 'd5', type: DrinkType.water, volume: 250, timestamp: today.add(const Duration(hours: 15, minutes: 20))),
    ]);
    notifyListeners();
  }
}
