import 'package:flutter/material.dart';

// --- BARREL IMPORT ---
import 'pages.dart'; 

// The main entry point now just wraps the Dashboard.
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply show the Dashboard as the primary content
    return const DashboardScreen();
  }
}