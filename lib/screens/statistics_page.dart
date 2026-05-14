import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../providers/settings_provider.dart';
import '../models/drink_record.dart';
import '../widgets/kpi_card.dart';
import '../widgets/hourly_vertical_bar_chart.dart';
import '../widgets/monthly_calendar.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/beverage_pie_chart.dart';
import '../widgets/insight_banner.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final goal = context.watch<SettingsProvider>().profile.dailyGoalMl;
        final hourlyData = provider.getHourlyDistribution();
        final weeklyData = provider.getWeeklyData();
        final breakdown = provider.getBeverageBreakdown();

        // ---- Computed KPIs ----
        final now = DateTime.now();
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final lastWeekStart = weekStart.subtract(const Duration(days: 7));

        double thisWeekTotal = 0;
        double lastWeekTotal = 0;
        final lastWeekDays = <int>{};

        for (final r in provider.records) {
          if (r.timestamp.isAfter(weekStart)) {
            thisWeekTotal += r.volume;
          } else if (r.timestamp.isAfter(lastWeekStart)) {
            lastWeekTotal += r.volume;
            lastWeekDays.add(r.timestamp.weekday);
          }
        }

        final daysElapsed = now.weekday;
        final avgDaily = daysElapsed > 0 ? thisWeekTotal / daysElapsed : 0.0;
        final avgLiters = avgDaily / 1000;

        final lastWeekAvg =
            lastWeekDays.isNotEmpty ? lastWeekTotal / 7 : null;
        final growthPct = lastWeekAvg != null && lastWeekAvg > 0
            ? ((avgDaily - lastWeekAvg) / lastWeekAvg * 100).round()
            : null;

        final goalRate =
            goal > 0 ? (provider.currentIntake / goal * 100).round() : 0;

        // ---- Smart insight (data-driven) ----
        final todayIntake = provider.currentIntake;
        final remaining = goal - todayIntake;
        String insightTitle;
        String insightDesc;

        if (todayIntake == 0) {
          insightTitle = '开始记录';
          insightDesc = '今天还没有记录饮水，点击「极速记录」开始追踪您的补水习惯吧！';
        } else if (goalRate >= 100) {
          insightTitle = '目标达成';
          insightDesc = '恭喜！您已经完成今日饮水目标。坚持良好的补水习惯有助于维持身体最佳状态。';
        } else if (goalRate >= 70) {
          insightTitle = '即将完成';
          insightDesc = '您已完成今日目标的 $goalRate%，还差约 ${remaining}ml。通常在下午 4 点前完成 80% 的摄入量效果最佳。';
        } else if (goalRate >= 40) {
          insightTitle = '稳步前进';
          insightDesc = '您已完成今日目标的 $goalRate%。下午是补水关键期，每小时补充 200-300ml 可以更轻松达标。';
        } else {
          insightTitle = '加快节奏';
          insightDesc = '您已完成 $goalRate%，距离目标还差 ${remaining}ml。早上和上午是最佳补水时段，现在开始还不晚！';
        }

        if (growthPct != null && growthPct > 20) {
          insightDesc += '本周平均摄入量较上周增长了 ${growthPct}%，继续保持！';
        }

        final pieData = <String, double>{
          '水': breakdown[DrinkType.water] ?? 0,
          '茶/咖啡': (breakdown[DrinkType.coffee] ?? 0) +
              (breakdown[DrinkType.tea] ?? 0),
          '其他': (breakdown[DrinkType.isotonic] ?? 0) +
              (breakdown[DrinkType.alcohol] ?? 0),
        };

        const pieColors = {
          '水': AppColors.primary,
          '茶/咖啡': Color(0xFF687780),
          '其他': AppColors.outlineVariant,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              '数据分析概览',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '关于您补水习惯的详细表现洞察。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            // KPI Grid
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: KpiCard(
                      label: '平均摄入量',
                      value: avgLiters.toStringAsFixed(1),
                      unit: '升/天',
                      footer: growthPct != null
                          ? Row(
                              children: [
                                Icon(
                                  growthPct >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: growthPct >= 0
                                      ? AppColors.secondary
                                      : AppColors.error,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '较上周${growthPct >= 0 ? '增长' : '减少'} ${growthPct.abs()}%',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: growthPct >= 0
                                          ? AppColors.secondary
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiCard(
                      label: '达标率',
                      value: '$goalRate',
                      unit: '%',
                      footer: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (goalRate / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hourly Line Chart
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '每小时补水曲线',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Icon(Icons.more_vert, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HourlyVerticalBarChart(data: hourlyData),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pie + Legend
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '饮品类型',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      BeveragePieChart(
                        breakdown: pieData,
                        colors: pieColors,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: pieData.entries
                              .where((e) => e.value > 0)
                              .map((e) {
                            final totalMl = provider.currentIntake;
                            final liters = e.value * totalMl / 1000;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: pieColors[e.key],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '${liters.toStringAsFixed(1)}升',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Bar Chart
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '每周达标情况',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '状态佳',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _tabChip('摄入量', true),
                          const SizedBox(width: 8),
                          _tabChip('频率', false),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeeklyBarChart(
                    data: weeklyData,
                    dailyGoalMl: goal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Calendar
            MonthlyCalendar(
              records: provider.records,
              dailyGoalMl: goal,
            ),
            const SizedBox(height: 24),

            // Smart Insight (data-driven)
            InsightBanner(
              icon: Icons.lightbulb,
              title: insightTitle,
              description: insightDesc,
              backgroundColor: const Color(0x33006E2F),
              foregroundColor: AppColors.onSecondaryContainer,
            ),
          ],
        );
      },
    );
  }

  Widget _tabChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceContainerHigh : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: active ? null : Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
