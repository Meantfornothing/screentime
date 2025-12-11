import 'package:flutter/material.dart';
// Core imports
import 'core/service_locator.dart' as di; 
import 'core/routes.dart';

// Presentation Layer imports
import 'features/app_recommendation/presentation/pages/main_wrapper.dart';
import 'features/app_recommendation/presentation/pages/dashboard_screen.dart';
import 'features/app_recommendation/presentation/pages/categorization_screen.dart';
import 'features/app_recommendation/presentation/pages/settings_screen.dart'; // Import Settings


void main() {
  // 1. Ensure Flutter widgets are initialized before services
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize all dependencies
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
        // Optional: Set the primary color to match your design globally
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4AF98)),
      ),
      
      initialRoute: AppRoutes.mainWrapper,
      routes: {
        AppRoutes.mainWrapper: (context) => const MainWrapper(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.categorization: (context) => const CategorizationScreen(),
        // FIX: Register the settings route
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}