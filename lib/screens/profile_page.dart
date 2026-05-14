import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_toggle_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final profile = settings.profile;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => _pickAvatar(context, settings),
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: profile.avatarUrl.isNotEmpty && File(profile.avatarUrl).existsSync()
                                ? Image.file(
                                    File(profile.avatarUrl),
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 48,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 48,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: AppColors.onPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  GestureDetector(
                    onTap: () => _editName(context, settings, profile),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 16, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Height & Weight inputs
                  Row(
                    children: [
                      Expanded(child: _NumberInputCard(
                        label: '身高 (cm)',
                        value: profile.height,
                        onChanged: (v) => settings.updateHeight(v),
                        hint: '175',
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _NumberInputCard(
                        label: '体重 (kg)',
                        value: profile.weight,
                        onChanged: (v) => settings.updateWeight(v),
                        hint: '70',
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BMI & Daily Goal
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '当前 BMI',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.bmi != null ? '${profile.bmi}' : '--',
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _editDailyGoal(context, settings, profile),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '每日目标',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.edit, size: 12, color: AppColors.onSurfaceVariant),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${profile.dailyGoalMl}ml',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Edit personal info button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditSheet(context, settings, profile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 20),
                      label: Text(
                        '修改个人信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hydration Coefficient Section
            Row(
              children: [
                const Icon(Icons.science, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  '补水系数',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primary,
                      child: Text(
                        '您的摄入量是通过饮品容量乘以补水指数计算得出的。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                    _coefficientRow(Icons.water, '纯水', '1.0x', AppColors.primary),
                    _coefficientRow(Icons.local_cafe, '黑咖啡', '0.8x', AppColors.tertiary),
                    _coefficientRow(Icons.energy_savings_leaf, '等渗运动饮料', '1.2x', AppColors.primary),
                    _coefficientRow(Icons.wine_bar, '酒精饮品', '-2.0x', AppColors.error, last: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // System Settings
            Text(
              '系统设置',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SettingsToggleTile(
                    icon: Icons.notifications_active,
                    iconColor: AppColors.primary,
                    title: '智能提醒',
                    subtitle: '基于活动的自适应警报',
                    trailing: PillSwitch(
                      value: settings.remindersEnabled,
                      onChanged: (_) => settings.toggleReminders(),
                    ),
                  ),
                  SettingsToggleTile(
                    icon: Icons.straighten,
                    title: '容量单位',
                    subtitle: '当前：${settings.unitLabel}',
                    trailing: SegmentedSelector(
                      left: 'ml',
                      right: 'oz',
                      isLeftSelected: settings.unit == VolumeUnit.ml,
                      onChanged: (isMl) {
                        settings.setUnit(isMl ? VolumeUnit.ml : VolumeUnit.oz);
                      },
                    ),
                  ),
                  SettingsToggleTile(
                    icon: Icons.palette,
                    title: '外观设置',
                    subtitle: '当前：深蓝色',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Info Footer
            Column(
              children: [
                Text(
                  'HydroPulse v1.0.6',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '每天喝水多一点',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ---------- Avatar ----------

  Future<void> _pickAvatar(BuildContext context, SettingsProvider settings) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        await settings.updateAvatar(image.path);
      }
    } catch (_) {}
  }

  // ---------- Name ----------

  Future<void> _editName(BuildContext context, SettingsProvider settings, UserProfile profile) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: profile.name);
        return AlertDialog(
          title: const Text('修改姓名'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: '请输入姓名',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      await settings.updateName(result);
    }
  }

  // ---------- Daily Goal ----------

  Future<void> _editDailyGoal(BuildContext context, SettingsProvider settings, UserProfile profile) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: '${profile.dailyGoalMl}');
        return AlertDialog(
          title: const Text('修改每日目标'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '请输入每日目标 (ml)',
              suffixText: 'ml',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      final goal = int.tryParse(result);
      if (goal != null && goal > 0) {
        await settings.updateDailyGoal(goal);
      }
    }
  }

  // ---------- Bottom Sheet ----------

  void _showEditSheet(BuildContext context, SettingsProvider settings, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileSheet(settings: settings, profile: profile),
    );
  }

  // ---------- Helpers ----------

  Widget _coefficientRow(IconData icon, String name, String coeff, Color color, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            coeff,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: coeff.startsWith('-') ? AppColors.error : AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInputCard extends StatefulWidget {
  final String label;
  final double? value;
  final ValueChanged<double> onChanged;
  final String hint;

  const _NumberInputCard({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  @override
  State<_NumberInputCard> createState() => _NumberInputCardState();
}

class _NumberInputCardState extends State<_NumberInputCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant _NumberInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double? v) {
    if (v == null) return '';
    return v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null && parsed > 0) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                letterSpacing: -0.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onSubmitted: (_) => _commit(),
            onTapOutside: (_) => _commit(),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final SettingsProvider settings;
  final UserProfile profile;

  const _EditProfileSheet({required this.settings, required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _goalCtrl;

  SettingsProvider get _settings => widget.settings;
  UserProfile get _profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _profile.name);
    _heightCtrl = TextEditingController(text: _profile.height?.toString() ?? '');
    _weightCtrl = TextEditingController(text: _profile.weight?.toString() ?? '');
    _goalCtrl = TextEditingController(text: '${_profile.dailyGoalMl}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        await _settings.updateAvatar(image.path);
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await _settings.updateName(name);
    }
    final height = double.tryParse(_heightCtrl.text);
    if (height != null && height > 0) {
      await _settings.updateHeight(height);
    }
    final weight = double.tryParse(_weightCtrl.text);
    if (weight != null && weight > 0) {
      await _settings.updateWeight(weight);
    }
    final goal = int.tryParse(_goalCtrl.text);
    if (goal != null && goal > 0) {
      await _settings.updateDailyGoal(goal);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    double? bmi;
    if (h != null && w != null && h > 0 && w > 0) {
      bmi = double.parse((w / ((h / 100) * (h / 100))).toStringAsFixed(1));
    }

    final profile = _settings.profile;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '修改个人信息',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: profile.avatarUrl.isNotEmpty &&
                                File(profile.avatarUrl).existsSync()
                            ? Image.file(
                                File(profile.avatarUrl),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 40,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: '姓名',
                hintText: '请输入姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Height & Weight
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: '身高 (cm)',
                      hintText: '175',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: '体重 (kg)',
                      hintText: '70',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // BMI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'BMI: ',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    bmi != null ? '$bmi' : '--',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    bmi != null ? _bmiCat(bmi) : '',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Goal
            TextField(
              controller: _goalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '每日目标 (ml)',
                hintText: '2850',
                suffixText: 'ml',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bmiCat(double? bmi) {
    if (bmi == null) return '';
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '偏胖';
    return '肥胖';
  }
}
