import 'dart:math'; 
import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_service.dart';

import '../../features/app_management/domain/entities/user_settings_entity.dart';

const String usageCheckTask = "usageCheckTask";

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
  await NotificationService.initialize();
  await Hive.initFlutter();
  
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserSettingsEntityAdapter());
  }

  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');
  final settings = settingsBox.get('user_settings') ?? UserSettingsEntity();

  try {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(hours: 24));
    List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

    // 1. Check Total Daily Goal
    int totalUsageMinutes = 0;
    for (var info in infoList) {
      totalUsageMinutes += info.usage.inMinutes;
    }
    
    if (totalUsageMinutes >= settings.dailyScreenTimeGoalMinutes) {
       await _sendNudge(
         id: 999,
         title: "Daily Goal Reached",
         body: "You've used ${totalUsageMinutes}m today. Time to disconnect?",
         intensity: settings.nudgeIntensity,
       );
       // We continue to check individual apps even if daily goal is met, 
       // to provide specific context.
    }

    // 2. Check Individual App Thresholds (Nudge Frequency Logic)
    // Threshold: 2 Hours (120 minutes)
    const int appUsageThreshold = 120; 

    // Frequency Logic:
    // Workmanager runs every ~15 mins.
    // frequency 1.0 => Notify every time (15 mins)
    // frequency 0.5 => Notify ~50% of the time (30 mins)
    // frequency 0.1 => Notify ~10% of the time (2.5 hours)
    final shouldNudge = Random().nextDouble() < settings.breakReminderFrequency;

    if (shouldNudge) {
      for (var info in infoList) {
        if (info.usage.inMinutes >= appUsageThreshold) {
           await _sendNudge(
             id: info.packageName.hashCode,
             title: "High Usage Alert",
             body: "You've been using ${info.appName} for ${info.usage.inMinutes}m today.",
             intensity: settings.nudgeIntensity,
           );
           break; // Notify for the most egregious app only to avoid spam
        }
      }
    }

  } catch (e) {
    print("Background Usage Check Failed: $e");
  } finally {
    await settingsBox.close();
  }
}

Future<void> _sendNudge({
  required int id,
  required String title,
  required String body,
  required double intensity,
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
  
  print("Sending Notification: $finalTitle"); 

  await NotificationService.showNotification(
    id: id,
    title: finalTitle,
    body: finalBody,
  );
}