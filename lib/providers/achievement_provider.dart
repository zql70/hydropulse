import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../models/challenge.dart';

class AchievementProvider extends ChangeNotifier {
  int level = 12;
  int xp = 0;
  int xpToNextLevel = 750;
  int totalXpForLevel = 1000;

  double get levelProgress {
    if (totalXpForLevel == 0) return 0;
    return (totalXpForLevel - xpToNextLevel) / totalXpForLevel;
  }

  late List<AppBadge> badges = [
    const AppBadge(id: 'b1', name: '第一滴水', icon: Icons.water_drop, isUnlocked: true),
    const AppBadge(id: 'b2', name: '7天连续', icon: Icons.calendar_today, isUnlocked: true),
    const AppBadge(id: 'b3', name: '饮水达人', icon: Icons.lock, isUnlocked: false),
    const AppBadge(id: 'b4', name: '深海传奇', icon: Icons.emoji_events, isUnlocked: false),
    const AppBadge(id: 'b5', name: '加仑目标', icon: Icons.local_drink, isUnlocked: false),
    const AppBadge(id: 'b6', name: '团队玩家', icon: Icons.groups, isUnlocked: false),
  ];

  late List<Challenge> challenges = [
    const Challenge(
      id: 'c1',
      name: '告别苏打周',
      description: '连续 7 天不饮用含糖碳酸饮料。',
      current: 4,
      target: 7,
      icon: Icons.no_drinks,
      unit: '天',
    ),
    const Challenge(
      id: 'c2',
      name: '晨起第一杯水',
      description: '在早上 8:00 前饮用 500ml 水。',
      current: 1,
      target: 1,
      icon: Icons.wb_sunny,
      hasReward: true,
      unit: '次',
    ),
  ];

  String get nextTitleName {
    if (level < 5) return '饮水新手';
    if (level < 10) return '饮水爱好者';
    if (level < 15) return '饮水达人';
    if (level < 20) return '深海传奇';
    return '水动力大师';
  }

  void claimReward(String challengeId) {
    final idx = challenges.indexWhere((c) => c.id == challengeId);
    if (idx == -1) return;
    final c = challenges[idx];
    if (!c.hasReward && c.isCompleted) return;

    challenges[idx] = Challenge(
      id: c.id,
      name: c.name,
      description: c.description,
      current: c.current,
      target: c.target,
      icon: c.icon,
      hasReward: false,
      unit: c.unit,
    );

    xpToNextLevel = (xpToNextLevel - 100).clamp(0, totalXpForLevel);
    if (xpToNextLevel == 0) {
      level++;
      totalXpForLevel = (totalXpForLevel * 1.2).round();
      xpToNextLevel = totalXpForLevel;
    }
    notifyListeners();
  }
}
