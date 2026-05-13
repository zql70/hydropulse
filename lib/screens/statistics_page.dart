import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../models/drink_record.dart';
import '../widgets/kpi_card.dart';
import '../widgets/hourly_bar_chart.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/beverage_pie_chart.dart';
import '../widgets/insight_banner.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final hourlyData = provider.getHourlyDistribution();
        final weeklyData = provider.getWeeklyData();
        final breakdown = provider.getBeverageBreakdown();

        final pieData = <String, double>{
          '水': breakdown[DrinkType.water] ?? 0.72,
          '茶/咖啡': (breakdown[DrinkType.coffee] ?? 0) +
              (breakdown[DrinkType.tea] ?? 0),
          '其他': (breakdown[DrinkType.isotonic] ?? 0) +
              (breakdown[DrinkType.alcohol] ?? 0),
        };

        if (pieData.values.every((v) => v == 0)) {
          pieData['水'] = 0.72;
          pieData['茶/咖啡'] = 0.20;
          pieData['其他'] = 0.08;
        }

        const pieColors = {
          '水': AppColors.primary,
          '茶/咖啡': Color(0xFF687780),
          '其他': AppColors.outlineVariant,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Header
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
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: '平均摄入量',
                    value: '2.4',
                    unit: '升/天',
                    footer: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '较上周增长 12%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    label: '达标率',
                    value: '94',
                    unit: '%',
                    footer: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 0.94,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: '咖啡因',
                    value: '320',
                    unit: '毫克',
                    valueColor: AppColors.tertiary,
                    footer: Text(
                      '中度摄入',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    label: '糖分',
                    value: '14',
                    unit: '克',
                    valueColor: AppColors.tertiary,
                    footer: Text(
                      '低水平',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Hourly Bar Chart
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
                  HourlyBarChart(data: hourlyData),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('08:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                      Text('12:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                      Text('16:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                      Text('20:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    ],
                  ),
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
                          children: pieData.entries.where((e) => e.value > 0).map((e) {
                            final volumes = {'水': '1.8升', '茶/咖啡': '0.4升', '其他': '0.2升'};
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
                                    volumes[e.key] ?? '',
                                    style: Theme.of(context).textTheme.labelMedium,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  WeeklyBarChart(data: weeklyData),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Smart Insight
            const InsightBanner(
              icon: Icons.lightbulb,
              title: '智能洞察',
              description: '您通常在下午 4 点前完成每日目标的 80%。在周末保持这种节奏可以将您的整体达标率提高 5%。',
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
