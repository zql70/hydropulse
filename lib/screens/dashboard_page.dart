import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
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
        final progress = provider.dailyProgress;
        final intake = provider.currentIntake;
        final goal = provider.dailyGoal;

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
