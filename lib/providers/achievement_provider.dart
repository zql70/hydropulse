import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../models/drink_record.dart';

class AchievementProvider extends ChangeNotifier {
  List<AppBadge> _badges = [];
  List<AppBadge> get badges => List.unmodifiable(_badges);

  int get totalPoints =>
      _badges.where((b) => b.isUnlocked).fold(0, (s, b) => s + b.points);
  int get unlockedCount => _badges.where((b) => b.isUnlocked).length;
  int get totalCount => _badges.length;
  double get completionRate =>
      totalCount > 0 ? unlockedCount / totalCount : 0;

  String get rankName {
    final pts = totalPoints;
    if (pts >= 10001) return '钻石';
    if (pts >= 5001) return '铂金';
    if (pts >= 2001) return '黄金';
    if (pts >= 501) return '白银';
    return '青铜';
  }

  int get rankMax {
    final pts = totalPoints;
    if (pts >= 10001) return 0;
    if (pts >= 5001) return 10001;
    if (pts >= 2001) return 5001;
    if (pts >= 501) return 2001;
    return 501;
  }

  int get rankMin {
    final pts = totalPoints;
    if (pts >= 10001) return 10001;
    if (pts >= 5001) return 5001;
    if (pts >= 2001) return 2001;
    if (pts >= 501) return 501;
    return 0;
  }

  double get rankProgress {
    if (rankMax == rankMin) return 1.0;
    return ((totalPoints - rankMin) / (rankMax - rankMin)).clamp(0.0, 1.0);
  }

  int _lastHash = 0;

  // ---- Compute achievements from real records ----

  void recompute(List<DrinkRecord> records, int dailyGoalMl) {
    final hash = records.length * 31 + dailyGoalMl;
    if (hash == _lastHash && _badges.isNotEmpty) return;
    _lastHash = hash;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Compute daily volumes
    final dailyVol = <String, int>{}; // 'yyyy-MM-dd' -> total ml
    for (final r in records) {
      final key =
          '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}-${r.timestamp.day.toString().padLeft(2, '0')}';
      dailyVol[key] = (dailyVol[key] ?? 0) + r.volume;
    }

    // Compute streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDays = dailyVol.keys.toList()..sort();
    String? lastDay;
    for (final day in sortedDays) {
      final met = (dailyVol[day] ?? 0) >= dailyGoalMl;
      if (met) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
      // Check if consecutive days
      if (lastDay != null) {
        final d1 = DateTime.parse(lastDay);
        final d2 = DateTime.parse(day);
        if (d2.difference(d1).inDays > 1) {
          tempStreak = met ? 1 : 0;
        }
      }
      lastDay = day;
    }
    // Current streak: count backwards from today
    currentStreak = 0;
    final sortedKeys = dailyVol.keys.toList()..sort((a, b) => b.compareTo(a));
    var check = today;
    for (final day in sortedKeys) {
      final d = DateTime.parse(day);
      if (d.isAfter(today)) continue;
      if (d == check && (dailyVol[day] ?? 0) >= dailyGoalMl) {
        currentStreak++;
        check = check.subtract(const Duration(days: 1));
      } else if (d.isBefore(check)) {
        break;
      }
    }

    // Total volume in liters
    final totalMl = dailyVol.values.fold(0, (a, b) => a + b);
    final totalL = totalMl / 1000;

    // Unique drink types
    final types = <DrinkType>{};
    for (final r in records) {
      if (r.timestamp.year == now.year && r.timestamp.month == now.month) {
        types.add(r.type);
      }
    }

    // Count beverage-specific volumes
    double teaMl = 0;
    double coffeeMl = 0;
    for (final r in records) {
      if (r.type == DrinkType.tea) teaMl += r.volume;
      if (r.type == DrinkType.coffee) coffeeMl += r.volume;
    }

    // Max daily volume
    int maxDaily = 0;
    for (final v in dailyVol.values) {
      if (v > maxDaily) maxDaily = v;
    }

    // Goal changes count (tracked via SharedPreferences)
    // Skip for now — needs cross-provider data

    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    _badges = [
      // === Streak (10) ===
      AppBadge(
        id: 's1', name: '初次相遇', description: '连续喝水1天', icon: 'water_drop',
        category: AchievementCategory.streak, rarity: AchievementRarity.normal,
        points: 10, current: currentStreak, target: 1,
        isUnlocked: currentStreak >= 1,
        unlockedAt: currentStreak >= 1 ? dateStr : null, progress: (currentStreak / 1).clamp(0, 1),
      ),
      AppBadge(
        id: 's2', name: '滴水穿石', description: '连续喝水3天', icon: 'water_drop',
        category: AchievementCategory.streak, rarity: AchievementRarity.normal,
        points: 20, current: currentStreak, target: 3,
        isUnlocked: currentStreak >= 3,
        unlockedAt: currentStreak >= 3 ? dateStr : null, progress: (currentStreak / 3).clamp(0, 1),
      ),
      AppBadge(
        id: 's3', name: '坚持不懈', description: '连续喝水7天', icon: 'local_fire_department',
        category: AchievementCategory.streak, rarity: AchievementRarity.rare,
        points: 50, current: currentStreak, target: 7,
        isUnlocked: currentStreak >= 7,
        unlockedAt: currentStreak >= 7 ? dateStr : null, progress: (currentStreak / 7).clamp(0, 1),
      ),
      AppBadge(
        id: 's4', name: '两周之约', description: '连续喝水14天', icon: 'local_fire_department',
        category: AchievementCategory.streak, rarity: AchievementRarity.rare,
        points: 100, current: currentStreak, target: 14,
        isUnlocked: currentStreak >= 14,
        unlockedAt: currentStreak >= 14 ? dateStr : null, progress: (currentStreak / 14).clamp(0, 1),
      ),
      AppBadge(
        id: 's5', name: '月度达人', description: '连续喝水30天', icon: 'emoji_events',
        category: AchievementCategory.streak, rarity: AchievementRarity.epic,
        points: 200, current: currentStreak, target: 30,
        isUnlocked: currentStreak >= 30,
        unlockedAt: currentStreak >= 30 ? dateStr : null, progress: (currentStreak / 30).clamp(0, 1),
      ),
      AppBadge(
        id: 's6', name: '季度冠军', description: '连续喝水90天', icon: 'emoji_events',
        category: AchievementCategory.streak, rarity: AchievementRarity.epic,
        points: 500, current: currentStreak, target: 90,
        isUnlocked: currentStreak >= 90,
        unlockedAt: currentStreak >= 90 ? dateStr : null, progress: (currentStreak / 90).clamp(0, 1),
      ),
      AppBadge(
        id: 's7', name: '半年坚持', description: '连续喝水180天', icon: 'military_tech',
        category: AchievementCategory.streak, rarity: AchievementRarity.legendary,
        points: 1000, current: currentStreak, target: 180,
        isUnlocked: currentStreak >= 180,
        unlockedAt: currentStreak >= 180 ? dateStr : null, progress: (currentStreak / 180).clamp(0, 1),
      ),
      AppBadge(
        id: 's8', name: '年度传奇', description: '连续喝水365天', icon: 'military_tech',
        category: AchievementCategory.streak, rarity: AchievementRarity.legendary,
        points: 2000, current: currentStreak, target: 365,
        isUnlocked: currentStreak >= 365,
        unlockedAt: currentStreak >= 365 ? dateStr : null, progress: (currentStreak / 365).clamp(0, 1),
      ),
      AppBadge(
        id: 's9', name: '永不放弃', description: '中断后重新连续7天', icon: 'refresh',
        category: AchievementCategory.streak, rarity: AchievementRarity.normal,
        points: 30, current: longestStreak >= 7 ? currentStreak : 0, target: 7,
        isUnlocked: longestStreak >= 7 && currentStreak >= 7,
        unlockedAt: longestStreak >= 7 && currentStreak >= 7 ? dateStr : null,
        progress: longestStreak >= 7 ? (currentStreak / 7).clamp(0, 1) : 0,
      ),
      AppBadge(
        id: 's10', name: '王者归来', description: '中断后重新连续30天', icon: 'refresh',
        category: AchievementCategory.streak, rarity: AchievementRarity.rare,
        points: 150, current: longestStreak >= 30 ? currentStreak : 0, target: 30,
        isUnlocked: longestStreak >= 30 && currentStreak >= 30,
        unlockedAt: longestStreak >= 30 && currentStreak >= 30 ? dateStr : null,
        progress: longestStreak >= 30 ? (currentStreak / 30).clamp(0, 1) : 0,
      ),

      // === Volume (10) ===
      AppBadge(
        id: 'v1', name: '第一杯水', description: '累计喝水1L', icon: 'cup',
        category: AchievementCategory.volume, rarity: AchievementRarity.normal,
        points: 10, current: totalL.toInt(), target: 1,
        isUnlocked: totalL >= 1, unlockedAt: totalL >= 1 ? dateStr : null,
        progress: (totalL / 1).clamp(0, 1),
      ),
      AppBadge(
        id: 'v2', name: '一桶水', description: '累计喝水10L', icon: 'cup',
        category: AchievementCategory.volume, rarity: AchievementRarity.normal,
        points: 20, current: totalL.toInt(), target: 10,
        isUnlocked: totalL >= 10, unlockedAt: totalL >= 10 ? dateStr : null,
        progress: (totalL / 10).clamp(0, 1),
      ),
      AppBadge(
        id: 'v3', name: '浴缸水量', description: '累计喝水100L', icon: 'bathtub',
        category: AchievementCategory.volume, rarity: AchievementRarity.rare,
        points: 50, current: totalL.toInt(), target: 100,
        isUnlocked: totalL >= 100, unlockedAt: totalL >= 100 ? dateStr : null,
        progress: (totalL / 100).clamp(0, 1),
      ),
      AppBadge(
        id: 'v4', name: '泳池一角', description: '累计喝水500L', icon: 'pool',
        category: AchievementCategory.volume, rarity: AchievementRarity.rare,
        points: 100, current: totalL.toInt(), target: 500,
        isUnlocked: totalL >= 500, unlockedAt: totalL >= 500 ? dateStr : null,
        progress: (totalL / 500).clamp(0, 1),
      ),
      AppBadge(
        id: 'v5', name: '小型泳池', description: '累计喝水1000L', icon: 'pool',
        category: AchievementCategory.volume, rarity: AchievementRarity.epic,
        points: 200, current: totalL.toInt(), target: 1000,
        isUnlocked: totalL >= 1000, unlockedAt: totalL >= 1000 ? dateStr : null,
        progress: (totalL / 1000).clamp(0, 1),
      ),
      AppBadge(
        id: 'v6', name: '标准泳池', description: '累计喝水5000L', icon: 'pool',
        category: AchievementCategory.volume, rarity: AchievementRarity.epic,
        points: 500, current: totalL.toInt(), target: 5000,
        isUnlocked: totalL >= 5000, unlockedAt: totalL >= 5000 ? dateStr : null,
        progress: (totalL / 5000).clamp(0, 1),
      ),
      AppBadge(
        id: 'v7', name: '湖泊水量', description: '累计喝水10000L', icon: 'waves',
        category: AchievementCategory.volume, rarity: AchievementRarity.legendary,
        points: 1000, current: totalL.toInt(), target: 10000,
        isUnlocked: totalL >= 10000, unlockedAt: totalL >= 10000 ? dateStr : null,
        progress: (totalL / 10000).clamp(0, 1),
      ),
      AppBadge(
        id: 'v8', name: '海洋之心', description: '累计喝水50000L', icon: 'diamond',
        category: AchievementCategory.volume, rarity: AchievementRarity.legendary,
        points: 2000, current: totalL.toInt(), target: 50000,
        isUnlocked: totalL >= 50000, unlockedAt: totalL >= 50000 ? dateStr : null,
        progress: (totalL / 50000).clamp(0, 1),
      ),
      AppBadge(
        id: 'v9', name: '今日冠军', description: '单日喝水超过3000ml', icon: 'emoji_events',
        category: AchievementCategory.volume, rarity: AchievementRarity.normal,
        points: 30, current: maxDaily, target: 3000,
        isUnlocked: maxDaily >= 3000, unlockedAt: maxDaily >= 3000 ? dateStr : null,
        progress: (maxDaily / 3000).clamp(0, 1),
      ),
      AppBadge(
        id: 'v10', name: '饮水大户', description: '单日喝水超过5000ml', icon: 'local_fire_department',
        category: AchievementCategory.volume, rarity: AchievementRarity.rare,
        points: 100, current: maxDaily, target: 5000,
        isUnlocked: maxDaily >= 5000, unlockedAt: maxDaily >= 5000 ? dateStr : null,
        progress: (maxDaily / 5000).clamp(0, 1),
      ),

      // === Discovery (5) ===
      AppBadge(
        id: 'd1', name: '尝鲜者', description: '记录5种不同饮品', icon: 'restaurant_menu',
        category: AchievementCategory.discovery, rarity: AchievementRarity.normal,
        points: 20, current: types.length, target: 5,
        isUnlocked: types.length >= 5, unlockedAt: types.length >= 5 ? dateStr : null,
        progress: (types.length / 5).clamp(0, 1),
      ),
      AppBadge(
        id: 'd2', name: '品茶大师', description: '累计喝茶1000ml', icon: 'emoji_food_beverage',
        category: AchievementCategory.discovery, rarity: AchievementRarity.rare,
        points: 50, current: teaMl.toInt(), target: 1000,
        isUnlocked: teaMl >= 1000, unlockedAt: teaMl >= 1000 ? dateStr : null,
        progress: (teaMl / 1000).clamp(0, 1),
      ),
      AppBadge(
        id: 'd3', name: '咖啡爱好者', description: '累计喝咖啡1000ml', icon: 'coffee',
        category: AchievementCategory.discovery, rarity: AchievementRarity.rare,
        points: 50, current: coffeeMl.toInt(), target: 1000,
        isUnlocked: coffeeMl >= 1000, unlockedAt: coffeeMl >= 1000 ? dateStr : null,
        progress: (coffeeMl / 1000).clamp(0, 1),
      ),
      AppBadge(
        id: 'd4', name: '定制达人', description: '修改3次喝水目标', icon: 'tune',
        category: AchievementCategory.discovery, rarity: AchievementRarity.normal,
        points: 10, current: 0, target: 3, isUnlocked: false, progress: 0,
      ),
      AppBadge(
        id: 'd5', name: '提醒大师', description: '设置5个不同的喝水提醒', icon: 'notifications_active',
        category: AchievementCategory.discovery, rarity: AchievementRarity.normal,
        points: 20, current: 0, target: 5, isUnlocked: false, progress: 0,
      ),

      // === Special (4) ===
      AppBadge(
        id: 'sp1', name: '新年第一杯', description: '1月1日喝水达标', icon: 'celebration',
        category: AchievementCategory.special, rarity: AchievementRarity.limited,
        points: 50,
        isUnlocked: now.month == 1 && now.day == 1 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl,
        unlockedAt: now.month == 1 && now.day == 1 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl ? dateStr : null,
        progress: now.month == 1 && now.day == 1 ? ((dailyVol[dateStr] ?? 0) / dailyGoalMl).clamp(0, 1) : 0,
      ),
      AppBadge(
        id: 'sp2', name: '夏日清凉', description: '7月1日喝水达标', icon: 'wb_sunny',
        category: AchievementCategory.special, rarity: AchievementRarity.limited,
        points: 50,
        isUnlocked: now.month == 7 && now.day == 1 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl,
        unlockedAt: now.month == 7 && now.day == 1 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl ? dateStr : null,
        progress: now.month == 7 && now.day == 1 ? ((dailyVol[dateStr] ?? 0) / dailyGoalMl).clamp(0, 1) : 0,
      ),
      AppBadge(
        id: 'sp3', name: '中秋团圆', description: '中秋节当天喝水达标', icon: 'nights_stay',
        category: AchievementCategory.special, rarity: AchievementRarity.limited,
        points: 50, isUnlocked: false, progress: 0,
      ),
      AppBadge(
        id: 'sp4', name: '世界水日', description: '3月22日喝水达标', icon: 'water',
        category: AchievementCategory.special, rarity: AchievementRarity.limited,
        points: 100,
        isUnlocked: now.month == 3 && now.day == 22 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl,
        unlockedAt: now.month == 3 && now.day == 22 && (dailyVol[dateStr] ?? 0) >= dailyGoalMl ? dateStr : null,
        progress: now.month == 3 && now.day == 22 ? ((dailyVol[dateStr] ?? 0) / dailyGoalMl).clamp(0, 1) : 0,
      ),
    ];

    notifyListeners();
  }
}
