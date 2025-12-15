import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'notification_service.dart';

// Unique name for the task
const String usageCheckTask = "usageCheckTask";

// Top-level function for Workmanager
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
  // 1. Initialize Notifications (Required in this isolate)
  await NotificationService.initialize();

  try {
    // 2. Fetch Usage Data directly (bypassing repo for simplicity in background)
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(hours: 24));
    List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

    // 3. Check Thresholds (e.g., 2 hours = 120 minutes)
    // In a real app, you'd fetch the user's specific limit from Hive here.
    const int limitInMinutes = 120; 

    for (var info in infoList) {
      // Example logic: specific app or all apps?
      // Let's say we check "Instagram" or "YouTube" specifically, 
      // or any app exceeding the limit.
      
      if (info.usage.inMinutes >= limitInMinutes) {
        // Send Notification
        await NotificationService.showNotification(
          id: info.packageName.hashCode, // Unique ID per app
          title: "Usage Alert!",
          body: "You've used ${info.appName} for over 2 hours today.",
        );
      }
    }
  } catch (e) {
    print("Background Usage Check Failed: $e");
  }
}