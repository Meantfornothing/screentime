import 'package:flutter/material.dart';
// Custom Widgets (For now, defined locally until we move them to /widgets)
// =================================================================

/// The styled card container for individual settings.
class SettingCard extends StatelessWidget {
  final Widget child;
  const SettingCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF98).withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}