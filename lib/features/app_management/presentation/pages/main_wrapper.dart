import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart'; //
import 'dashboard_screen.dart'; //

/// A simple shell for the application's primary content.
/// Directly hosts the [DashboardScreen] as the primary view.
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the Dashboard in a Scaffold or Container to ensure the 
    // background color matches our brand theme from the very start.
    return const Scaffold(
      backgroundColor: AppColors.background, //
      body: DashboardScreen(), //
    );
  }
}