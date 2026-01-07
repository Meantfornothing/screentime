import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart';

/// The styled card container for individual settings.
class SettingCard extends StatelessWidget {
  final Widget child;
  const SettingCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Use surface color defined for cards in app_visuals.dart
        color: AppColors.background, 
        // Use the standardized card border radius (16.0)
        borderRadius: AppShapes.cardBorder, 
        border: Border.all(
          // Use primary brand color with low opacity for a soft border
          color: AppColors.primary.withOpacity(0.7), 
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}