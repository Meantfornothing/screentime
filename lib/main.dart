import 'package:flutter/material.dart';

// 1. Import the service locator function from the core layer
import 'core/service_locator.dart' as di; 
// 2. Import the screen you want to display first
import 'features/app_recommendation/presentation/pages/categorization_screen.dart'; 

void main() {
  // MUST be called before any calls to native services or packages 
  // (like Firebase, or our Platform Channel setup later).
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Initialize all dependencies (Data Source, Repositories, Use Cases)
  // This executes the logic inside lib/core/service_locator.dart
  di.init(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usage Monitor App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using Inter font for modern aesthetics
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      // 4. Set the home to your starting screen
      home: const CategorizationScreen(), 
    );
  }
}