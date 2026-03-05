import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: iOS));
  }

  static Future<void> showReminder(int id, String title, String body) async {
    const android = AndroidNotificationDetails('tum_reminders', 'Reminders', channelDescription: 'Reminder channel', importance: Importance.max, priority: Priority.high);
    const iOS = DarwinNotificationDetails();
    await _plugin.show(id, title, body, const NotificationDetails(android: android, iOS: iOS));
  }
}
