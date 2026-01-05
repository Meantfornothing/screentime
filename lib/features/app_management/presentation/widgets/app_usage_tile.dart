import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart';

class AppUsageTile extends StatelessWidget {
  final String appName;
  final Duration duration;
  final dynamic iconBytes; // Assuming Uint8List or similar
  final String categoryName;

  const AppUsageTile({
    super.key,
    required this.appName,
    required this.duration,
    required this.categoryName,
    this.iconBytes,
  });

  @override
  Widget build(BuildContext context) {
    // 1. The Card now inherits elevation: 0, AppColors.surface, 
    // and AppShapes.cardBorder automatically from your theme.
    return Card(
      margin: const EdgeInsets.only(bottom: 12), 
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: iconBytes != null && iconBytes!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  iconBytes!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  // 2. Using AppColors for consistency
                  color: AppColors.background, 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: AppColors.textSecondary),
              ),
        title: Text(
          appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            color: AppColors.textPrimary, // 3. Themed text color
          ),
        ),
        subtitle: Text(
          categoryName,
          style: const TextStyle(
            fontSize: 11, 
            color: AppColors.textSecondary, // 4. Themed secondary text
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${duration.inMinutes}m",
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              "today",
              style: TextStyle(
                fontSize: 10, 
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}