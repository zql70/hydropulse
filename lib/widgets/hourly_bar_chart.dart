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
    const barAreaH = 130.0;
    const bottomReserve = 24.0;
    const labelGap = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartW = constraints.maxWidth;
        final barCount = data.length;
        final maxDisplayY = chartMax * 1.2;
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
                    maxY: maxDisplayY,
                    barGroups: data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.toDouble(),
                            color: AppColors.primary,
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
                          reservedSize: bottomReserve,
                          getTitlesWidget: (value, meta) {
                            const labels = [
                              '8时', '10时', '12时', '14时',
                              '16时', '18时', '20时', '22时',
                            ];
                            final i = value.toInt();
                            if (i < 0 || i >= labels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[i],
                                style: const TextStyle(
                                  fontSize: 9,
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
              ),
              // Value labels above bars — fixed pixel gap from bar top
              for (var i = 0; i < barCount; i++)
                if (data[i].value > 0)
                  Positioned(
                    left: chartW / barCount * (i + 0.5) - 22,
                    bottom: bottomReserve +
                        drawH * (data[i].value / maxDisplayY) +
                        labelGap,
                    child: SizedBox(
                      width: 44,
                      child: Text(
                        '${data[i].value}ml',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
