import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:self_life_monitoring_app/screens/home_screen.dart';
import '../main.dart'; // ✅ for navigatorKey

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Initialize + handle notification click
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // ✅ OPEN SCREEN WHEN NOTIFICATION CLICKED
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => HomeScreen(contacts: []),
          ),
        );
      },
    );
  }

  // ✅ Show Persistent + Lock Screen Notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'monitoring_channel',
      'Safety Monitoring',
      channelDescription: 'Notifications for monitoring status',

      importance: Importance.max,
      priority: Priority.high,

      ongoing: true,       // 🔒 not swipeable
      autoCancel: false,   // ❌ stays until STOP

      playSound: true,
      enableVibration: false,

      visibility: NotificationVisibility.public, // 🔒 lock screen
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  // ✅ Cancel notification
  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}