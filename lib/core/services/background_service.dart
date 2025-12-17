import 'dart:math'; // Import for random logic
import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notification_service.dart';

// Import Settings Entity
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
  // 1. Initialize dependencies
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

    // --- LOGIC: Total Daily Goal ---
    int totalUsageMinutes = 0;
    for (var info in infoList) {
      totalUsageMinutes += info.usage.inMinutes;
    }
    
    // Check Daily Goal
    if (totalUsageMinutes >= settings.dailyScreenTimeGoalMinutes) {
       await _sendNudge(
         id: 999,
         title: "Daily Goal Reached",
         body: "You've used ${totalUsageMinutes}m today. Time to disconnect?",
         intensity: settings.nudgeIntensity,
       );
       return; // Stop here if daily goal hit (priority)
    }

    // --- LOGIC: Break Reminders (Steered by breakReminderFrequency) ---
    // breakReminderFrequency is 0.0 (Rare) to 1.0 (Frequent).
    // Workmanager runs every ~15 mins.
    // If frequency is high (1.0), we notify almost every check if usage is high.
    // If frequency is low (0.1), we notify rarely.
    
    // Simple probabilistic check based on frequency setting:
    // If Random() < frequency, we proceed to check app usage.
    // This makes the notification appearing "randomly" but steered by the setting.
    final shouldCheckBreak = Random().nextDouble() < settings.breakReminderFrequency;

    if (shouldCheckBreak) {
      // Find the app used most recently/heavily in the last 24h
      // (Note: Android API doesn't give "current" open app easily in background without permission hurdles,
      // so we use high usage apps as proxy for "likely using")
      
      for (var info in infoList) {
        // If an individual app has high usage (e.g. > 30 mins)
        if (info.usage.inMinutes > 30) {
           await _sendNudge(
             id: info.packageName.hashCode,
             title: "Break Time?",
             body: "You've been on ${info.appName} for a while (${info.usage.inMinutes}m).",
             intensity: settings.nudgeIntensity,
           );
           break; // Notify for just one app to avoid spam
        }
      }
    }

  } catch (e) {
    print("Background Usage Check Failed: $e");
  } finally {
    await settingsBox.close();
  }
}

// Helper to format notification based on Intensity
Future<void> _sendNudge({
  required int id,
  required String title,
  required String body,
  required double intensity,
}) async {
  String finalTitle = title;
  String finalBody = body;

  // Steering behavior based on Nudge Intensity (0.0 - 1.0)
  if (intensity > 0.8) {
    // Aggressive
    finalTitle = "STOP SCROLLING!";
    finalBody = body.toUpperCase() + " PUT THE PHONE DOWN NOW.";
  } else if (intensity < 0.3) {
    // Gentle
    finalTitle = "Gentle Nudge";
    finalBody = "Hey there, $body Maybe stretch a bit?";
  }
  
  print("Sending Notification: $finalTitle - $finalBody"); // Log for debugging

  await NotificationService.showNotification(
    id: id,
    title: finalTitle,
    body: finalBody,
  );
}