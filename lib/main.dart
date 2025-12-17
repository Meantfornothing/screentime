import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart'; 
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';

// Import services and entities directly
import 'core/services/background_service.dart'; // Contains callbackDispatcher and usageCheckTask
import 'core/services/notification_service.dart';
import 'features/app_management/presentation/pages/pages.dart';
import 'features/app_management/domain/entities/entities.dart';
import 'features/app_management/presentation/pages/preferences_screen.dart';

// Helper function definition for MyApp class (assuming it's defined at the bottom)
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
  
  // 1. Initialize Hive & DI
  await Hive.initFlutter();
  Hive.registerAdapter(AppCategoryEntityAdapter());
  Hive.registerAdapter(InstalledAppAdapter());
  // Ensure UserSettingsEntityAdapter is registered (assuming it is TypeId 2)
  Hive.registerAdapter(UserSettingsEntityAdapter());

  // Open Boxes
  await Hive.openBox<AppCategoryEntity>('categories');
  await Hive.openBox<InstalledApp>('installed_apps');
  await Hive.openBox<UserSettingsEntity>('settings');

  // --- Temporary Mock Data (COMMENT OUT AFTER TESTING) ---
  // Note: Since we are saving settings via the UI now, we don't need this
  // unless we are testing the background service immediately after first install.
  // await _initializeMockDataForTesting(Hive.box('settings'), ...);
  // --------------------------------------------------------

  di.init(); 

  // 2. Initialize Notifications (Foreground)
  await NotificationService.initialize();

  // 3. Initialize Workmanager and schedule task
  await Workmanager().initialize(
    callbackDispatcher, 
    isInDebugMode: true 
  );

  // 4. Schedule the Periodic Task
  await Workmanager().registerPeriodicTask(
    "1", // Job ID
    usageCheckTask, // Task Name
    frequency: const Duration(minutes: 15),
    constraints: Constraints(),
  );
  
  runApp(const MyApp());
}