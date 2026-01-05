import 'package:flutter/material.dart';

class AppColors {
  // ... Existing Colors (Primary, Neutral, Functional) ...
  static const Color primary = Color(0xFFD4AF98);
  static const Color primaryVariant = Color(0xFFB8967E);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  

  // --- NEW: Category Specific Colors ---
  static const Color productivity = Color(0xFF2E7D32); // Green
  static const Color entertainment = Color(0xFFBA1A1A); // Red
  static const Color social = Color(0xFF1976D2);       // Blue
  static const Color health = Color(0xFFE91E63);       // Pink
  static const Color neutral = Color(0xFF607D8B);      // Blue Grey

  /// Static method to retrieve color based on category name
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Productivity':
        return productivity;
      case 'Entertainment':
        return entertainment;
      case 'Social':
        return social;
      case 'Health & Fitness':
        return health;
      case 'Neutral':
        return neutral;
      case 'Uncategorized':
      case '':
        return textSecondary.withOpacity(0.4);
      default:
        // Fallback for custom categories using a hash-based color
        final customColors = [
          Colors.teal,
          Colors.indigo,
          Colors.amber,
          Colors.cyan,
          Colors.deepOrange,
        ];
        return customColors[category.hashCode.abs() % customColors.length];
    }
  }
}

class AppShapes {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(cardRadius));
}
/// Specialized box for settings and navigation icons.
/// This is NOT intended for app icons from the phone.
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AppIconBox({
    required this.icon,
    this.color = AppColors.primary,
    this.size = 22.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}