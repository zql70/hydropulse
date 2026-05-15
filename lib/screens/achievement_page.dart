import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/achievement_provider.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../models/badge.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  AchievementCategory _activeCategory = AchievementCategory.all;

  static const _categories = [
    AchievementCategory.all,
    AchievementCategory.streak,
    AchievementCategory.volume,
    AchievementCategory.discovery,
    AchievementCategory.special,
  ];

  static const _catLabels = ['全部', '连续打卡', '累计水量', '探索发现', '特殊纪念'];

  @override
  Widget build(BuildContext context) {
    final hydration = context.watch<HydrationProvider>();
    final goal = context.watch<SettingsProvider>().profile.dailyGoalMl;

    return Consumer<AchievementProvider>(
      builder: (context, provider, _) {
        provider.recompute(hydration.records, goal);

        final filtered = _activeCategory == AchievementCategory.all
            ? provider.badges
            : provider.badges
                .where((b) => b.category == _activeCategory)
                .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ---- Circular progress + stats ----
            _SummaryHeader(provider: provider),
            const SizedBox(height: 20),

            // ---- Category tabs ----
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = cat == _activeCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1976D2)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _catLabels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ---- Badge grid ----
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events, size: 48, color: Color(0xFFE0E0E0)),
                    SizedBox(height: 8),
                    Text('该分类暂无成就', style: TextStyle(color: Color(0xFF999999))),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.92,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, idx) =>
                    _BadgeTile(badge: filtered[idx]),
              ),
            const SizedBox(height: 24),

            // ---- Rank info ----
            _RankCard(provider: provider),
          ],
        );
      },
    );
  }
}

// ---- Summary header ----
class _SummaryHeader extends StatelessWidget {
  final AchievementProvider provider;
  const _SummaryHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular progress
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: provider.completionRate,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF1976D2)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(provider.completionRate * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Text(
                    '成就进度',
                    style: TextStyle(fontSize: 10, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stat cards
        Row(
          children: [
            Expanded(child: _MiniStat(value: '${provider.unlockedCount}/${provider.totalCount}', label: '已解锁')),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(value: '${provider.totalPoints}点', label: '成就点数')),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(value: '${provider.rankName}', label: '当前等级')),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}

// ---- Badge tile ----
class _BadgeTile extends StatelessWidget {
  final AppBadge badge;
  const _BadgeTile({required this.badge});

  Color get _borderColor {
    if (!badge.isUnlocked) return const Color(0xFFE0E0E0);
    switch (badge.rarity) {
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700);
      case AchievementRarity.epic:
        return const Color(0xFFAB47BC);
      case AchievementRarity.rare:
        return const Color(0xFF1976D2);
      case AchievementRarity.limited:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  Color get _bgColor {
    if (!badge.isUnlocked) return const Color(0xFFF5F5F5);
    switch (badge.rarity) {
      case AchievementRarity.legendary:
        return const Color(0xFFFFF8E1);
      case AchievementRarity.epic:
        return const Color(0xFFF3E5F5);
      default:
        return Colors.white;
    }
  }

  IconData get _iconData {
    switch (badge.icon) {
      case 'water_drop': return Icons.water_drop;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'emoji_events': return Icons.emoji_events;
      case 'military_tech': return Icons.military_tech;
      case 'refresh': return Icons.refresh;
      case 'cup': return Icons.coffee; // generic cup
      case 'bathtub': return Icons.bathtub;
      case 'pool': return Icons.pool;
      case 'waves': return Icons.waves;
      case 'diamond': return Icons.diamond;
      case 'restaurant_menu': return Icons.restaurant_menu;
      case 'emoji_food_beverage': return Icons.emoji_food_beverage;
      case 'coffee': return Icons.coffee;
      case 'tune': return Icons.tune;
      case 'notifications_active': return Icons.notifications_active;
      case 'celebration': return Icons.celebration;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'nights_stay': return Icons.nights_stay;
      case 'water': return Icons.water;
      default: return Icons.emoji_events;
    }
  }

  String get _rarityLabel {
    switch (badge.rarity) {
      case AchievementRarity.normal: return '普通';
      case AchievementRarity.rare: return '稀有';
      case AchievementRarity.epic: return '史诗';
      case AchievementRarity.legendary: return '传说';
      case AchievementRarity.limited: return '限时';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: badge.isUnlocked ? 1.5 : 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? const Color(0xFF1976D2).withValues(alpha: 0.1)
                    : const Color(0xFFEEEEEE),
              ),
              child: Icon(
                _iconData,
                size: 28,
                color: badge.isUnlocked
                    ? const Color(0xFF1976D2)
                    : const Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: badge.isUnlocked
                    ? const Color(0xFF333333)
                    : const Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(height: 2),
            // Progress or check
            if (badge.isUnlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 12, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 2),
                  Text(
                    '+${badge.points}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF4CAF50)),
                  ),
                ],
              )
            else
              Text(
                '${badge.current}/${badge.target}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Large icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isUnlocked
                      ? const Color(0xFF1976D2).withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  border: Border.all(color: _borderColor, width: 2),
                ),
                child: Icon(
                  _iconData,
                  size: 40,
                  color: badge.isUnlocked
                      ? const Color(0xFF1976D2)
                      : const Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 12),
              Text(badge.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(badge.description, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_rarityLabel · +${badge.points}点',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              ),
              if (badge.isUnlocked && badge.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text('获得于 ${badge.unlockedAt}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
              if (!badge.isUnlocked) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: badge.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1976D2)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('进度 ${badge.current}/${badge.target}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ],
          ),
        ),
        );
      },
    );
  }
}

// ---- Rank card ----
class _RankCard extends StatelessWidget {
  final AchievementProvider provider;
  const _RankCard({required this.provider});

  static const _rankColors = {
    '青铜': Color(0xFFCD7F32),
    '白银': Color(0xFFC0C0C0),
    '黄金': Color(0xFFFFD700),
    '铂金': Color(0xFFE5E4E2),
    '钻石': Color(0xFFB9F2FF),
  };

  @override
  Widget build(BuildContext context) {
    final color = _rankColors[provider.rankName] ?? const Color(0xFFCD7F32);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.military_tech, size: 32, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前等级：${provider.rankName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: provider.rankProgress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 2),
                Text('${provider.totalPoints} / ${provider.rankMax > 0 ? provider.rankMax : provider.totalPoints} 点',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
