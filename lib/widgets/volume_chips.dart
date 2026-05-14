import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VolumeChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> volumes;

  const VolumeChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.volumes = const ['200ml', '300ml', '500ml', '自定义'],
  });

  void _showCustomDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义饮水量'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入毫升数',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && int.tryParse(value) != null) {
                onSelected('${value}ml');
                Navigator.pop(ctx);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: volumes.map((v) {
          final isSelected = v == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              elevation: isSelected ? 2 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (v == '自定义') {
                    _showCustomDialog(context);
                  } else {
                    onSelected(v);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Text(
                    v,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
