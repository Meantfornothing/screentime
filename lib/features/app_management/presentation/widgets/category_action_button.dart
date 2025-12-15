import 'package:flutter/material.dart';

// =================================================================
// Feature-Specific Widgets (In lib/features/.../presentation/widgets)
// =================================================================

/// Replicates the button for adding a category (Top of the screen).
class CategoryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const CategoryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Icon(icon, size: 24),
        ],
      ),
    );
  }
}