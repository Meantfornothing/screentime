import 'package:flutter/material.dart';
// Core imports
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';

// Presentation Layer imports
import 'features/app_recommendation/presentation/pages/main_wrapper.dart';
import 'features/app_recommendation/presentation/pages/dashboard_screen.dart';
import 'features/app_recommendation/presentation/pages/categorization_screen.dart';


void main() {
  // 1. Ensure Flutter widgets are initialized before services
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize all dependencies (from lib/core/service_locator.dart)
  di.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScreenTime Monitor', // Updated title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      
      // Use named routes for clean navigation
      initialRoute: AppRoutes.mainWrapper,
      routes: {
        // Main wrapper hosts the Bottom Nav Bar and is the starting screen
        AppRoutes.mainWrapper: (context) => const MainWrapper(),
        
        // Defining these pages here allows them to be navigated to directly
        // if needed, though they are primarily loaded by the MainWrapper's IndexedStack.
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.categorization: (context) => const CategorizationScreen(),
        // AppRoutes.settings: (context) => const SettingsScreen(), // Add Settings when you create it
      },
    );
  }
}