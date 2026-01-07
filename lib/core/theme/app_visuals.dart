import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 155, 173, 137);
  static const Color primaryVariant = Color.fromARGB(255, 159, 173, 144);
  static const Color background = Colors.white;
  static const Color surface = Color.fromARGB(255, 199, 212, 186);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color.fromARGB(255, 61, 61, 61);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  
  static const Color productivity = Color.fromARGB(255, 35, 17, 235);
  static const Color entertainment = Color.fromARGB(255, 230, 116, 10);
  static const Color social = Color.fromARGB(255, 225, 229, 34);
  static const Color relaxation = Color.fromARGB(255, 175, 15, 223);
  static const Color neutral = Color.fromARGB(255, 133, 132, 133);

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Productivity': return productivity;
      case 'Entertainment': return entertainment;
      case 'Social': return social;
      case 'Relaxation': return relaxation;
      case 'Neutral': return const Color.fromARGB(255, 133, 132, 133);
      default: return const Color.fromARGB(255, 133, 132, 133);
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
    this.color = const Color.fromARGB(255, 67, 71, 63),
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