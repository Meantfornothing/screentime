import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD4AF98);
  static const Color primaryVariant = Color(0xFFB8967E);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  
  static const Color productivity = Color(0xFF2E7D32);
  static const Color entertainment = Color(0xFFBA1A1A);
  static const Color social = Color(0xFF1976D2);
  static const Color relaxation = Color(0xFF00BCD4);
  static const Color neutral = Color(0xFF607D8B);

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Productivity': return productivity;
      case 'Entertainment': return entertainment;
      case 'Social': return social;
      case 'Relaxation': return relaxation;
      case 'Neutral': return neutral;
      default: return neutral;
    }
  }
}

class AppShapes {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(cardRadius));
}

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