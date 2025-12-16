import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // On iOS, we need to request permissions explicitly
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // 1. Define BigTextStyle for expanded view
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: '<b>$title</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Usage Alert', // Small text next to app name
      htmlFormatSummaryText: true,
    );

    // 2. Android Specifics
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'usage_monitor_channel', 
      'Usage Monitor', 
      channelDescription: 'Notifications for screen time limits',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: const Color(0xFFD4AF98), // Use your app's brand color (Beige/Brown)
      styleInformation: bigTextStyleInformation, // Apply the big text style
      // Optional: Add actions
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'snooze_action', 
          'Snooze 10m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    // 3. iOS Specifics
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}