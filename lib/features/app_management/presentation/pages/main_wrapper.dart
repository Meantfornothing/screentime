import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

/// A simple shell for the application's primary content.
/// Since bottom navigation is removed, this directly hosts the [DashboardScreen].
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return the DashboardScreen. 
    // Navigation to other screens (like UsageTimeScreen) is handled 
    // via Navigator.push inside the widgets.
    return const DashboardScreen();
  }
}