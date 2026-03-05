import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(settings: settings);
  }

  static Future<void> showReminder(int id, String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      'tum_reminders',
      'Reminders',
      channelDescription: 'Reminder channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}
