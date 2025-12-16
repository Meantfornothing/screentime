import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
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
  // 1. Initialize dependencies in background isolate
  await NotificationService.initialize();
  await Hive.initFlutter();
  
  // Register necessary adapters
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserSettingsEntityAdapter());
  }

  // Open the settings box
  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');
  final settings = settingsBox.get('user_settings') ?? UserSettingsEntity(); // Get or default

  try {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(hours: 24));
    List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

    // 2. Use Settings for Logic
    // Example: Use daily goal as the threshold
    final int limitInMinutes = settings.dailyScreenTimeGoalMinutes; 
    
    // Example: Use nudge intensity to change the message tone
    String title = "Usage Alert";
    String body = "You've exceeded your goal.";
    
    if (settings.nudgeIntensity > 0.7) {
      title = "Time's Up!";
      body = "Seriously, put the phone down. You hit your ${limitInMinutes}m limit.";
    } else if (settings.nudgeIntensity < 0.3) {
      title = "Gentle Reminder";
      body = "You've reached your daily goal. Maybe take a break?";
    }

    // 3. Check Usage against Goal
    // Note: AppUsage returns total time for ALL apps or individual?
    // infoList contains individual apps. To check TOTAL daily screen time, we sum them up.
    
    int totalUsageMinutes = 0;
    for (var info in infoList) {
      totalUsageMinutes += info.usage.inMinutes;
    }

    // Trigger notification if total usage exceeds the user's goal
    // We store a flag or check if we haven't notified yet to avoid spamming?
    // For simplicity, we notify if over limit.
    if (totalUsageMinutes >= limitInMinutes) {
       await NotificationService.showNotification(
          id: 999, // Static ID for daily goal
          title: title,
          body: "$body (Used: ${totalUsageMinutes}m / Goal: ${limitInMinutes}m)",
        );
    }

  } catch (e) {
    print("Background Usage Check Failed: $e");
  } finally {
    // Close Hive box to be safe
    await settingsBox.close();
  }
}