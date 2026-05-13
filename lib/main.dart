import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hydration_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/notification_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final hydrationProvider = HydrationProvider();
  hydrationProvider.seedDemoData();

  final achievementProvider = AchievementProvider();
  final notificationProvider = NotificationProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: hydrationProvider),
        ChangeNotifierProvider.value(value: achievementProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: const HydroPulseApp(),
    ),
  );

  // Init notifications after app starts
  await notificationProvider.init();
  if (settingsProvider.remindersEnabled) {
    await notificationProvider.scheduleDefaultReminders();
  }
}
