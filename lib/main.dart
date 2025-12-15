import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart'; // Import Workmanager
import 'core/services/services.dart'; 
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';


// FIX: Updated path from 'app_recommendation' to 'app_management' based on your folder rename
import 'features/app_management/presentation/pages/pages.dart';
import 'features/app_management/domain/entities/entities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Hive & DI
  await Hive.initFlutter();
  Hive.registerAdapter(AppCategoryEntityAdapter());
  Hive.registerAdapter(InstalledAppAdapter());
  await Hive.openBox<AppCategoryEntity>('categories');
  await Hive.openBox<InstalledApp>('installed_apps');
  di.init(); 

  // 2. Initialize Notifications (Foreground)
  await NotificationService.initialize();

  // 3. Initialize Workmanager
  // callbackDispatcher is the top-level function from background_service.dart
  await Workmanager().initialize(
    callbackDispatcher, 
    isInDebugMode: true // Set to false for release
  );

  // 4. Schedule the Periodic Task (e.g., every 15 minutes)
  // Android restriction: Minimum frequency is 15 minutes.
  await Workmanager().registerPeriodicTask(
    "1", // Unique ID
    usageCheckTask, // Task Name
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
  
  runApp(const MyApp());
}

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
      },
    );
  }
}