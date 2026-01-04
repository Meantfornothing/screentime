import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart';

class CategorySummaryTile extends StatelessWidget {
  final String categoryName;
  final Duration duration;

  const CategorySummaryTile({
    super.key,
    required this.categoryName,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    // Formatting the duration logic
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface, // Light grey background
        borderRadius: AppShapes.cardBorder, // 16.0 radius
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Category Label
          Expanded(
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary, // #1A1A1A
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Time Indicator (Pill style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15), // Light beige tint
              borderRadius: BorderRadius.circular(AppShapes.buttonRadius), // 12.0 radius
            ),
            child: Text(
              durationText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryVariant, // Darker beige for contrast
              ),
            ),
          ),
        ],
      ),
    );
  }
}