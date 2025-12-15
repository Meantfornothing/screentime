import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
// Core imports
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';

// Presentation Layer imports
import 'features/app_recommendation/presentation/pages/pages.dart';

// Import Entities for Adapter Registration
import 'features/app_recommendation/domain/entities/entities.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register Adapters (We will add these to the entity files next)
  Hive.registerAdapter(AppCategoryEntityAdapter());
  Hive.registerAdapter(InstalledAppAdapter());

  // 3. Open Boxes (Tables)
  await Hive.openBox<AppCategoryEntity>('categories');
  await Hive.openBox<InstalledApp>('installed_apps'); // To store assignments

  // 4. Initialize Service Locator
  di.init(); 
  
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