import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VolumeChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  final List<int> customVolumes;
  final ValueChanged<int> onAddCustom;
  final ValueChanged<int> onRemoveCustom;

  static const presets = [200, 300, 500];

  const VolumeChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.customVolumes = const [],
    required this.onAddCustom,
    required this.onRemoveCustom,
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
              final value = int.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                onSelected(value);
                onAddCustom(value);
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
    final allVolumes = [
      ...presets,
      ...customVolumes,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const columns = 4;
        final chipWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final v in allVolumes)
              SizedBox(
                width: chipWidth,
                child: customVolumes.contains(v)
                    ? _CustomChip(
                        volume: v,
                        isSelected: v == selected,
                        onTap: () => onSelected(v),
                        onDelete: () => onRemoveCustom(v),
                      )
                    : _PresetChip(
                        volume: v,
                        isSelected: v == selected,
                        onTap: () => onSelected(v),
                      ),
              ),
            // Add custom button
            SizedBox(
              width: chipWidth,
              child: _AddChip(onTap: () => _showCustomDialog(context)),
            ),
          ],
        );
      },
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int volume;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.volume,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 2 : 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            '${volume}ml',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final int volume;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomChip({
    required this.volume,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant;

    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 2 : 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${volume}ml',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fgColor,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(
            Icons.add,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
