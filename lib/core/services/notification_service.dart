import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // UPDATED: Added named parameters for callbacks
  static Future<void> initialize({
    void Function(NotificationResponse)? onNotificationResponse,
    void Function(NotificationResponse)? onBackgroundNotificationResponse,
  }) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // UPDATED: Passing the callbacks to the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: '<b>$title</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Usage Alert',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'usage_monitor_channel', 
      'Usage Monitor', 
      channelDescription: 'Notifications for screen time limits',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: const Color(0xFFD4AF98),
      styleInformation: bigTextStyleInformation,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'snooze_action', 
          'Snooze 10m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

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