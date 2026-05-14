import 'package:flutter/material.dart';

class HourlyHorizontalBarChart extends StatelessWidget {
  final List<MapEntry<int, int>> data; // hour 0..23 -> volume ml

  const HourlyHorizontalBarChart({super.key, required this.data});

  static const _barH = 28.0;
  static const _gap = 10.0;
  static const _labelW = 32.0;
  static const _valueW = 52.0;
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _darkBlue = Color(0xFF1976D2);
  static const _emptyGray = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final maxVol =
        data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final effectiveMax = maxVol > 0 ? maxVol : 400.0;

    return Column(
      children: [
        for (final e in data)
          _HourRow(
            hour: e.key,
            volume: e.value,
            maxVolume: effectiveMax,
            showLabel: e.key % 2 == 0,
          ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  final int hour;
  final int volume;
  final double maxVolume;
  final bool showLabel;

  const _HourRow({
    required this.hour,
    required this.volume,
    required this.maxVolume,
    required this.showLabel,
  });

  String get _hourText => '${hour.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final hasVolume = volume > 0;
    final rowH = HourlyHorizontalBarChart._barH + HourlyHorizontalBarChart._gap;

    return SizedBox(
      height: rowH,
      child: Row(
        children: [
          // Hour label
          SizedBox(
            width: HourlyHorizontalBarChart._labelW,
            child: showLabel
                ? Text(
                    _hourText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9E9E9E),
                      height: 1,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          // Bar area
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: hasVolume
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final barW =
                            (volume / maxVolume) * constraints.maxWidth;
                        return Container(
                          height: HourlyHorizontalBarChart._barH,
                          width: barW.clamp(4.0, constraints.maxWidth),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                HourlyHorizontalBarChart._barH / 2),
                            gradient: const LinearGradient(
                              colors: [
                                HourlyHorizontalBarChart._lightBlue,
                                HourlyHorizontalBarChart._darkBlue,
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: HourlyHorizontalBarChart._barH,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HourlyHorizontalBarChart._emptyGray,
                        borderRadius: BorderRadius.circular(
                            HourlyHorizontalBarChart._barH / 2),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          // Value label
          SizedBox(
            width: HourlyHorizontalBarChart._valueW,
            child: hasVolume
                ? Text(
                    '${volume}ml',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: HourlyHorizontalBarChart._darkBlue,
                      height: 1,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
