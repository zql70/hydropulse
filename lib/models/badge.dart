enum AchievementCategory { all, streak, volume, discovery, special }

enum AchievementRarity { normal, rare, epic, legendary, limited }

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int points;
  final bool isUnlocked;
  final double progress;
  final int current;
  final int target;
  final String? unlockedAt;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.rarity = AchievementRarity.normal,
    this.points = 10,
    this.isUnlocked = false,
    this.progress = 0,
    this.current = 0,
    this.target = 1,
    this.unlockedAt,
  });

  AppBadge copyWith({
    bool? isUnlocked,
    double? progress,
    int? current,
    String? unlockedAt,
  }) {
    return AppBadge(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      rarity: rarity,
      points: points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      current: current ?? this.current,
      target: target,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
