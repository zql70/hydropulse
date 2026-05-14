import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/drink_record.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/circular_progress_gauge.dart';
import '../widgets/volume_chips.dart';
import '../widgets/beverage_grid.dart';
import '../widgets/insight_banner.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final settings = context.watch<SettingsProvider>();
        final goal = settings.profile.dailyGoalMl;
        final intake = provider.currentIntake;
        final progress = goal > 0 ? intake / goal : 0.0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Circular progress gauge
            Center(
              child: CircularProgressGauge(
                progress: progress.clamp(0, 1),
                valueText: '${(progress * 100).round()}%',
                subtitle: '$intake / ${goal}ml',
              ),
            ),
            const SizedBox(height: 8),
            // Next reminder
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '下次提醒: ',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '14:45',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Drink Score card
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '饮水评分',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Icon(Icons.verified, color: AppColors.secondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.drinkScore}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '表现优秀',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Log Section
            Text(
              '极速记录',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Volume Chips
            VolumeChips(
              selected: provider.selectedVolume,
              onSelected: provider.selectVolume,
              customVolumes: provider.customVolumes,
              onAddCustom: provider.addCustomVolume,
              onRemoveCustom: provider.removeCustomVolume,
            ),
            const SizedBox(height: 12),

            // Beverage Grid
            BeverageGrid(
              selected: provider.selectedType,
              onSelected: provider.selectType,
            ),
            const SizedBox(height: 16),

            // Record button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => provider.addDrink(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_circle),
                label: Text(
                  '记录饮水',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Records
            _TodayRecordsList(records: provider.todayRecords),
            const SizedBox(height: 24),

            // Insight Banner
            const InsightBanner(
              icon: Icons.lightbulb,
              title: '每日洞察',
              description: '在记录运动的日子里，您的饮水量会增加 20%。请继续保持！',
              backgroundColor: Color(0x33006E2F),
              foregroundColor: AppColors.onSecondaryContainer,
            ),
          ],
        );
      },
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 128,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TodayRecordsList extends StatelessWidget {
  final List<DrinkRecord> records;

  const _TodayRecordsList({required this.records});

  IconData _iconForType(DrinkType type) => switch (type) {
    DrinkType.water => Icons.water_drop,
    DrinkType.coffee => Icons.coffee,
    DrinkType.tea => Icons.emoji_food_beverage,
    DrinkType.isotonic => Icons.bolt,
    DrinkType.alcohol => Icons.wine_bar,
  };

  Color _colorForType(DrinkType type) => switch (type) {
    DrinkType.water => AppColors.primary,
    DrinkType.coffee => const Color(0xFF6F4E37),
    DrinkType.tea => AppColors.secondary,
    DrinkType.isotonic => const Color(0xFFE8752A),
    DrinkType.alcohol => AppColors.error,
  };

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日记录',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              '今天还没有记录，快喝杯水吧！',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...records.asMap().entries.map((e) {
            final idx = e.key;
            final r = e.value;
            final isFirst = idx == 0;
            final isLast = idx == records.length - 1;
            return _RecordTile(
              icon: _iconForType(r.type),
              iconColor: _colorForType(r.type),
              label: r.type.label,
              volume: '${r.volume}ml',
              time: _formatTime(r.timestamp),
              isFirst: isFirst,
              isLast: isLast,
              onDelete: () {
                context.read<HydrationProvider>().removeRecord(r.id);
              },
            );
          }),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String volume;
  final String time;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;

  const _RecordTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.volume,
    required this.time,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.outlineVariant),
          right: BorderSide(color: AppColors.outlineVariant),
          top: const BorderSide(color: AppColors.outlineVariant),
          bottom: isLast
              ? const BorderSide(color: AppColors.outlineVariant)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              volume,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
