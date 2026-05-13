import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> scheduleReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _dailyTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydropulse_reminder',
          'Hydration Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDefaultReminders() async {
    await scheduleReminder(
      id: 1, hour: 9, minute: 0,
      title: 'HydroPulse',
      body: '该喝水了！已经一个小时没补充水分了。',
    );
    await scheduleReminder(
      id: 2, hour: 11, minute: 0,
      title: 'HydroPulse',
      body: '补水时间！保持水分摄入有助于集中注意力。',
    );
    await scheduleReminder(
      id: 3, hour: 14, minute: 45,
      title: 'HydroPulse',
      body: '下午好！喝杯水提提神吧。',
    );
    await scheduleReminder(
      id: 4, hour: 16, minute: 30,
      title: 'HydroPulse',
      body: '距离今日目标还有一段距离，继续加油！',
    );
    await scheduleReminder(
      id: 5, hour: 18, minute: 30,
      title: 'HydroPulse',
      body: '晚餐前来杯水，有助于消化健康。',
    );
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  tz.TZDateTime _dailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
