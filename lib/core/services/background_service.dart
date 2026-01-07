import 'dart:math'; 
import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

import 'package:screentime/features/app_management/domain/entities/user_settings_entity.dart';
import 'package:screentime/features/app_management/domain/entities/installed_app_entity.dart';

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

    const int appUsageThreshold = 45; // 2 hours
    final shouldNudge = Random().nextDouble() < settings.breakReminderFrequency;

    if (shouldNudge) {
      for (var info in infoList) {
        if (info.usage.inMinutes >= appUsageThreshold) {
           final appData = installedAppsBox.values.firstWhere(
             (app) => app.packageName == info.packageName,
             orElse: () => InstalledApp(packageName: info.packageName, name: info.appName),
           );

           // Logic: If they are using a Productivity app too much, suggest Entertainment.
           // Otherwise, suggest moving back to Productivity.
           final bool isProductive = appData.assignedCategoryName == 'Productivity';
           final String targetCategory = isProductive ? 'Entertainment' : 'Productivity';
           final String? payload = isProductive ? 'target_category:Entertainment' : null;

           // Delegate all presentation logic (intensity/strings) to NotificationService
           await NotificationService.showNudge(
             id: info.packageName.hashCode,
             intensity: settings.nudgeIntensity,
             category: targetCategory,
             payload: payload,
           );
           
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