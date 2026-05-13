import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HourlyBarChart extends StatelessWidget {
  final List<MapEntry<int, int>> data;

  const HourlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data
        .map((e) => e.value.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final chartMax = (maxY > 0 ? maxY : 400).toDouble();

    return SizedBox(
      height: 192,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMax * 1.2,
          barGroups: data.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final isPrimary = i == 3 || i == 4;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  color: isPrimary
                      ? AppColors.primary
                      : AppColors.surfaceContainerHigh,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = ['08:00', '12:00', '16:00', '20:00'];
                  final indices = [0, 2, 4, 6];
                  final idx = indices.indexOf(value.toInt());
                  if (idx == -1) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}
