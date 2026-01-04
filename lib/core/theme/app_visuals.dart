import 'package:flutter/material.dart';
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFFD4AF98); // Your existing beige
  static const Color primaryVariant = Color(0xFFB8967E);
  
  // Neutral Palette
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA); // Very light grey for cards
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  
  // Functional Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
}

class AppShapes {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(cardRadius));
}