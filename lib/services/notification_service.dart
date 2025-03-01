import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleWeeklyReminder(int number) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weekly_reminder',
          '週間リマインダー',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 毎週日曜日の10時に通知
    await notificationsPlugin.zonedSchedule(
      1,
      '⚠️在庫が少なくなっています',
      '在庫が少ない消耗品が$number個あります',
      _nextInstanceOfSunday10AM(),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /*Future<void> scheduleRunningOutNotification(
    String itemName,
    int daysLeft,
  ) async {
    if (daysLeft <= 7) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'running_out',
            '残り少ない商品',
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await notificationsPlugin.show(
        2,
        '在庫が少なくなっています',
        '$itemNameの残りがあと$daysLeft日分です',
        notificationDetails,
      );
    }
  }*/

  tz.TZDateTime _nextInstanceOfSunday10AM() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      30,
    );

    while (scheduledDate.weekday != DateTime.saturday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }
}
