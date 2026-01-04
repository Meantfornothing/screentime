import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart'; //

class CategoryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color; // Made optional to support the theme default
  final VoidCallback onPressed;

  const CategoryActionButton({
    required this.label,
    required this.icon,
    this.color, // Optional: defaults to theme primary if null
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // 1. Only override the background if a specific color is passed
        backgroundColor: color, 
        // 2. Keep the unique layout requirements (full width)
        minimumSize: const Size(double.infinity, 50),
        // 3. Ensure the shape matches your app constants
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 24),
        ],
      ),
    );
  }
}