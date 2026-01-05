// lib/core/services/notification_service.dart

import 'dart:async'; // Required for StreamController
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // A broadcast stream to allow multiple widgets to listen for notification taps
  static final _onTapController = StreamController<String?>.broadcast();
  static Stream<String?> get onTapStream => _onTapController.stream;

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

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Emit the payload to the stream
        _onTapController.add(response.payload);
        onNotificationResponse?.call(response);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );
    // ADD THIS BLOCK: Request Android 13+ permissions explicitly
    final androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Checks if the app was launched via a notification tap (Terminated state)
  static Future<NotificationResponse?> getAppLaunchDetails() async {
    final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return details?.notificationResponse;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // ... (rest of your existing showNotification logic)
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