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
    final Color categoryColor = AppColors.getCategoryColor(categoryName);

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppShapes.cardBorder,
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Time Indicator (Pill style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // 2. Use the category color with low opacity for the background
                  color: categoryColor.withOpacity(0.40), 
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                ),
                child: Text(
                  durationText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    // 3. Use the full category color for the text
                    color: Color.fromARGB(255, 61, 61, 61), 
                  ),
                ),
              ),
            ],
          ),
        );
      }
}