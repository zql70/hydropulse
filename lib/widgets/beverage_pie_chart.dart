import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BeveragePieChart extends StatelessWidget {
  final Map<String, double> breakdown; // label -> percentage
  final Map<String, Color> colors;

  const BeveragePieChart({
    super.key,
    required this.breakdown,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return const SizedBox(
        height: 128,
        child: Center(child: Text('暂无数据')),
      );
    }

    return SizedBox(
      height: 128,
      width: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: entries.map((e) {
                return PieChartSectionData(
                  value: e.value * 100,
                  color: colors[e.key] ?? AppColors.outlineVariant,
                  showTitle: false,
                  radius: 24,
                );
              }).toList(),
              centerSpaceRadius: 30,
              sectionsSpace: 3,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(breakdown['水'] ?? 0 * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Text(
                '水',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
