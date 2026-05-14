import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> data; // 0.0 ~ 1.0
  final int dailyGoalMl;

  const WeeklyBarChart({
    super.key,
    required this.data,
    this.dailyGoalMl = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final todayIdx = DateTime.now().weekday - 1;
    final maxBar = data.reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxBar > 1.0 ? maxBar * 1.2 : 1.2;
    const barAreaH = 130.0;
    const bottomReserve = 24.0;
    const labelGap = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartW = constraints.maxWidth;
        final drawH = barAreaH - bottomReserve;
        return SizedBox(
          height: barAreaH + 32,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: barAreaH,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    barGroups: List.generate(7, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data[i],
                            color: i == todayIdx
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : AppColors.primary,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }),
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
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            const labels = [
                              '一', '二', '三', '四', '五', '六', '日'
                            ];
                            final i = value.toInt();
                            final isToday = i == todayIdx;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isToday ? FontWeight.bold : FontWeight.w400,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.outline,
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
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 1.0,
                          color: AppColors.primary,
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Value labels above bars
              for (var i = 0; i < 7; i++)
                if (data[i] > 0)
                  Positioned(
                    left: chartW / 7 * (i + 0.5) - 24,
                    bottom: bottomReserve + drawH * (data[i] / chartMaxY) + labelGap,
                    child: SizedBox(
                      width: 48,
                      child: Text(
                        '${(data[i] * dailyGoalMl).round()}ml',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: i == todayIdx
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : AppColors.primary,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
