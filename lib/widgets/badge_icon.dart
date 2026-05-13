import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/badge.dart';

class BadgeIcon extends StatelessWidget {
  final AppBadge badge;

  const BadgeIcon({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: badge.isUnlocked
                ? const LinearGradient(
                    colors: [Color(0xFFE3F2FD), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: badge.isUnlocked ? null : AppColors.surfaceContainerHigh,
            boxShadow: badge.isUnlocked
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            badge.isUnlocked ? badge.icon : Icons.lock,
            color: badge.isUnlocked ? Colors.white : AppColors.outline,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.name,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? AppColors.secondaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badge.isUnlocked ? '已获得' : '未解锁',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badge.isUnlocked
                  ? AppColors.onSecondaryContainer
                  : AppColors.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }
}
