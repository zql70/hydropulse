import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/drink_record.dart';

class BeverageGrid extends StatelessWidget {
  final DrinkType selected;
  final ValueChanged<DrinkType> onSelected;

  const BeverageGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _items = [
    (DrinkType.water, Icons.water_drop, '纯水'),
    (DrinkType.coffee, Icons.coffee, '咖啡'),
    (DrinkType.tea, Icons.emoji_food_beverage, '茶饮'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items.map((item) {
        final (type, icon, label) = item;
        final isSelected = type == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != _items.last.$1 ? 12 : 0,
            ),
            child: Material(
              color: isSelected
                  ? AppColors.surfaceContainerLow
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
