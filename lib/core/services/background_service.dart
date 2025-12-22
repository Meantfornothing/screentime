import 'dart:math'; 
import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

import '../../features/app_management/domain/entities/user_settings_entity.dart';
import '../../features/app_management/domain/entities/installed_app_entity.dart';

const String usageCheckTask = "usageCheckTask";

// UPDATED: This function handles taps when the app is closed
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("Background Tap Payload: ${notificationResponse.payload}");
}

@pragma('vm:entry-point') 
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == usageCheckTask) {
      await _checkUsageAndNotify();
    }
    return Future.value(true);
  });
}

Future<void> _checkUsageAndNotify() async {
  // Pass the background callback here too
  await NotificationService.initialize(
    onBackgroundNotificationResponse: notificationTapBackground,
  );
  
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserSettingsEntityAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(InstalledAppAdapter());

  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');
  final installedAppsBox = await Hive.openBox<InstalledApp>('installed_apps');
  final settings = settingsBox.get('user_settings') ?? UserSettingsEntity();

  try {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(hours: 24));
    List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

    const int appUsageThreshold = 120; // 2 hours
    final shouldNudge = Random().nextDouble() < settings.breakReminderFrequency;

    if (shouldNudge) {
      for (var info in infoList) {
        if (info.usage.inMinutes >= appUsageThreshold) {
           final appData = installedAppsBox.values.firstWhere(
             (app) => app.packageName == info.packageName,
             orElse: () => InstalledApp(packageName: info.packageName, name: info.appName),
           );

           if (appData.assignedCategoryName == 'Productivity') {
               await _sendNudge(
                 id: info.packageName.hashCode,
                 title: "Great work!",
                 body: "You've been productive. Swap to Entertainment?",
                 intensity: settings.nudgeIntensity,
                 payload: 'target_category:Entertainment', // <--- Trigger swap filter
               );
           } else {
               await _sendNudge(
                 id: info.packageName.hashCode,
                 title: "High Usage Alert",
                 body: "You've been using ${info.appName} for ${info.usage.inMinutes}m.",
                 intensity: settings.nudgeIntensity,
               );
           }
           break; 
        }
      }
    }
  } catch (e) {
    print("Background Usage Check Failed: $e");
  } finally {
    await settingsBox.close();
    await installedAppsBox.close();
  }
}

Future<void> _sendNudge({
  required int id,
  required String title,
  required String body,
  required double intensity,
  String? payload,
}) async {
  String finalTitle = title;
  String finalBody = body;

  if (intensity > 0.8) {
    finalTitle = "STOP SCROLLING!";
    finalBody = body.toUpperCase() + " PUT THE PHONE DOWN.";
  } else if (intensity < 0.3) {
    finalTitle = "Gentle Nudge";
    finalBody = "Hey, $body maybe take a breath?";
  }
  
  await NotificationService.showNotification(
    id: id,
    title: finalTitle,
    body: finalBody,
    payload: payload,
  );
}