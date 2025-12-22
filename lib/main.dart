import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';

import 'core/services/background_service.dart'; // Imports notificationTapBackground
import 'core/services/notification_service.dart';
import 'features/app_management/presentation/pages/pages.dart';
import 'features/app_management/domain/entities/entities.dart';
import 'features/app_management/presentation/pages/preferences_screen.dart';

// UPDATED: Global variable for the swap logic
String? pendingCategoryFilter;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScreenTime Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF98)),
      ),
      initialRoute: AppRoutes.mainWrapper,
      routes: {
        AppRoutes.mainWrapper: (context) => const MainWrapper(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.categorization: (context) => const CategorizationScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.preferences: (context) => const PreferencesScreen(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(AppCategoryEntityAdapter());
  Hive.registerAdapter(InstalledAppAdapter());
  Hive.registerAdapter(UserSettingsEntityAdapter());

  await Hive.openBox<AppCategoryEntity>('categories');
  await Hive.openBox<InstalledApp>('installed_apps');
  await Hive.openBox<UserSettingsEntity>('settings');

  di.init(); 

  // UPDATED: Initializing with both foreground and background callbacks
  await NotificationService.initialize(
    onNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.startsWith('target_category:')) {
        pendingCategoryFilter = payload.split(':')[1];
      }
    },
    onBackgroundNotificationResponse: notificationTapBackground,
  );

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Workmanager().registerPeriodicTask(
    "1", 
    usageCheckTask, 
    frequency: const Duration(minutes: 15),
    constraints: Constraints(),
  );
  
  runApp(const MyApp());
}