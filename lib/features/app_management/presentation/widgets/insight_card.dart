import 'package:flutter/material.dart';
import '../pages/usage_time_screen.dart';
import '../../../../core/theme/app_visuals.dart';

class InsightCard extends StatelessWidget {
  final String content;

  const InsightCard({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Use a subtle gradient from a low-opacity primary to the surface color
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3), // Subtle beige tint at top-left
            AppColors.surface, // Fades to near-white/surface at bottom-right
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppShapes.cardBorder, // 16.0 radius
        boxShadow: [
          BoxShadow(
            // Use a very soft, neutral shadow for depth
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        // Optional: Add a thin, transparent border for more definition
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon and text are now dark for contrast against the light background
              Icon(Icons.auto_awesome, color: AppColors.textPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                "DAILY INSIGHT",
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textPrimary, // Main content is dark
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsageTimeScreen()),
                );
              },
              style: TextButton.styleFrom(
                // Button background is a very subtle primary tint
                backgroundColor: AppColors.primary.withOpacity(0.1),
                // Button text/icon are dark
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius), // 12.0 radius
                ),
                elevation: 0, // Remove button shadow for a flatter look
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Detailed Usage",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}