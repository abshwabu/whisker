import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _notificationMessages = [
    "Whisker missed you today 🐾",
    "Someone's asking for pets...",
    "Whisker is looking around for you... 😺",
    "Time to cuddle with Whisker! 💖",
    "Have you fed Whisker today? 🍽️",
    "Whisker is curled up waiting for you...💤",
  ];

  Future<void> init() async {
    // 1. Initialize time zones
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // Fallback if local location cannot be resolved
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Initialize local notifications settings
    // Using @mipmap/ic_launcher because it exists in all standard Flutter Android projects
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> checkFirstLaunchPermission(BuildContext context) async {
    final box = await Hive.openBox('appSettingsBox');
    final bool hasPrompted = box.get('hasPromptedPermission', defaultValue: false);
    if (!hasPrompted) {
      // Show friendly explain dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFFFF9F8),
            title: const Text(
              'Daily Reminder',
              style: TextStyle(color: Color(0xFF4A3E3D), fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Want a daily nudge to check in on Whisker? 🐾 We\'ll remind you at your preferred time.',
              style: TextStyle(color: Color(0xFF4A3E3D)),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await box.put('hasPromptedPermission', true);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB5A7),
                ),
                onPressed: () async {
                  await box.put('hasPromptedPermission', true);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  await requestPermission();
                },
                child: const Text('Yes, Please!'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> requestPermission() async {
    try {
      // Request for Android (API 33+)
      final androidResult = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Request for iOS
      final iosResult = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Schedule default notification at 6:00 PM if permissions are granted
      await scheduleDailyNotification(hour: 18, minute: 0);

      return (androidResult ?? false) || (iosResult ?? false);
    } catch (_) {
      return false; // Safely fail and continue core loop
    }
  }

  Future<void> scheduleDailyNotification({required int hour, required int minute}) async {
    try {
      // 1. Cancel previous notifications to prevent duplicates
      await flutterLocalNotificationsPlugin.cancelAll();

      // 2. Select a random message copy
      final random = Random();
      final String bodyText = _notificationMessages[random.nextInt(_notificationMessages.length)];

      // 3. Schedule the zoned daily reminder
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Whisker',
        body: bodyText,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_whisker_channel_id',
            'Daily Whisker Reminders',
            channelDescription: 'Friendly daily reminders to take care of Whisker',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save scheduled time in settings for retrieval in Settings screen
      final box = await Hive.openBox('appSettingsBox');
      await box.put('reminderHour', hour);
      await box.put('reminderMinute', minute);
      await box.put('reminderEnabled', true);
    } catch (_) {
      // Fully offline and non-blocking if permission is denied
    }
  }

  Future<void> disableNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    final box = await Hive.openBox('appSettingsBox');
    await box.put('reminderEnabled', false);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
