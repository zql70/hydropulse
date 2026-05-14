import 'package:flutter/material.dart';

class HourlyVerticalBarChart extends StatelessWidget {
  final List<MapEntry<int, int>> data; // bucket start hour → volume ml

  const HourlyVerticalBarChart({super.key, required this.data});

  static const _lightBlue = Color(0xFFE3F2FD);
  static const _darkBlue = Color(0xFF1976D2);
  static const _emptyGray = Color(0xFFF5F5F5);
  static const _barW = 18.0;
  static const _radius = 5.0;
  static const _chartH = 150.0;
  static const _bottomSpace = 28.0;
  static const _labelGap = 6.0;

  String _bucketLabel(int hour) {
    if (hour == 0) return '0-8';
    return '$hour';
  }

  @override
  Widget build(BuildContext context) {
    final maxV = data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final chartMax = maxV > 0 ? maxV * 1.25 : 500.0;
    final drawH = _chartH - _bottomSpace;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartW = constraints.maxWidth;
        final n = data.length;
        final slotW = chartW / n;

        return SizedBox(
          height: _chartH + 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bars
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: _chartH,
                child: CustomPaint(
                  painter: _GridPainter(bottomY: _bottomSpace),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: _bottomSpace),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.asMap().entries.map((e) {
                        final d = e.value;
                        final barH = d.value > 0
                            ? (d.value / chartMax) * drawH
                            : 0.0;
                        return SizedBox(
                          width: slotW,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: barH.clamp(0.0, drawH),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: const Radius.circular(_radius),
                                    bottom: barH <= 0.1
                                        ? const Radius.circular(_radius)
                                        : Radius.zero,
                                  ),
                                  gradient: d.value > 0
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [_lightBlue, _darkBlue],
                                        )
                                      : null,
                                  color: d.value > 0 ? null : _emptyGray,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // X-axis labels
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  children: data.map((d) {
                    return SizedBox(
                      width: slotW,
                      child: Center(
                        child: Text(
                          _bucketLabel(d.key),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Value labels above bars
              for (var i = 0; i < n; i++)
                if (data[i].value > 0)
                  Positioned(
                    left: slotW * i + slotW / 2 - 22,
                    bottom: _bottomSpace +
                        (data[i].value / chartMax) * drawH +
                        _labelGap,
                    child: SizedBox(
                      width: 44,
                      child: Text(
                        '${data[i].value}ml',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _darkBlue,
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

class _GridPainter extends CustomPainter {
  final double bottomY;
  _GridPainter({this.bottomY = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;
    final y = size.height - bottomY;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      bottomY != oldDelegate.bottomY;
}
