// lib/core/services/notification_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import your logic utility
import '../utils/nudge_logic.dart'; 

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
        _onTapController.add(response.payload);
        onNotificationResponse?.call(response);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );

    final androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<NotificationResponse?> getAppLaunchDetails() async {
    final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return details?.notificationResponse;
  }

  /// New specialized method to handle intensity-based nudges
  static Future<void> showNudge({
    required int id,
    required double intensity,
    required String category,
    String? payload,
  }) async {
    // 1. Use NudgeLogic to get strings based on intensity
    final String title = NudgeLogic.getTitle(intensity);
    final String body = NudgeLogic.getBody(intensity, category);

    // 2. Map intensity to Android Importance levels
    Importance importance;
    if (intensity >= 0.7) {
      importance = Importance.max; // High priority, intrusive
    } else if (intensity < 0.3) {
      importance = Importance.defaultImportance; // Subtle
    } else {
      importance = Importance.high; // Standard alert
    }

    // 3. Forward to the generic showNotification method
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      importance: importance,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Importance importance = Importance.max, 
  }) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: '<b>$title</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Goal Nudge',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'realign_goals_channel', 
      'ReAlign Goals',         
      channelDescription: 'Notifications to help you stick to your focus goals',
      importance: importance,
      priority: importance == Importance.max ? Priority.high : Priority.defaultPriority,
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