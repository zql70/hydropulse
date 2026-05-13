import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CircularProgressGauge extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final String valueText;
  final String subtitle;
  final double size;

  const CircularProgressGauge({
    super.key,
    required this.progress,
    required this.valueText,
    required this.subtitle,
    this.size = 256,
  });

  @override
  Widget build(BuildContext context) {
    final strokeWidth = 12.0;
    final radius = (size - strokeWidth) / 2;
    final circumference = 2 * pi * radius;
    final progressDash = circumference * progress.clamp(0, 1);
    final remainingDash = circumference - progressDash;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: Transform.rotate(
              angle: -pi / 2,
              child: CustomPaint(
                painter: _GaugePainter(
                  progressDash: progressDash,
                  remainingDash: remainingDash,
                  strokeWidth: strokeWidth,
                  circumference: circumference,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: size * 0.22,
            child: Container(
              width: size * 0.5,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progressDash;
  final double remainingDash;
  final double strokeWidth;
  final double circumference;

  _GaugePainter({
    required this.progressDash,
    required this.remainingDash,
    required this.strokeWidth,
    required this.circumference,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (progressDash / (pi * 2 * radius)) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      progressDash != oldDelegate.progressDash;
}
