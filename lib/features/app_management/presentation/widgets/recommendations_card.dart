import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../../../core/theme/app_visuals.dart';

class RecommendationsCard extends StatelessWidget {
  final String content;
  final List<InstalledApp> recommendedApps;
  final Color Function(String categoryName) getCategoryColor;

  const RecommendationsCard({
    required this.content,
    required this.recommendedApps,
    required this.getCategoryColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface, // Clean light grey for secondary info
        borderRadius: AppShapes.cardBorder,
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 18),
          if (recommendedApps.isEmpty)
            const Text(
              "No apps categorized for recommendation yet.", 
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.start,
              children: recommendedApps.map((app) => _RecommendedAppIcon(
                    appName: app.name,
                    packageName: app.packageName,
                    categoryColor: getCategoryColor(app.assignedCategoryName ?? ''),
                    iconBytes: app.iconBytes,
                    key: ValueKey(app.packageName),
                  )).toList(),
            ),
        ],
      ),
    );
  }
}

class _RecommendedAppIcon extends StatelessWidget {
  final String appName;
  final String packageName;
  final Color categoryColor;
  final Uint8List? iconBytes;

  const _RecommendedAppIcon({
    required this.appName,
    required this.packageName,
    required this.categoryColor,
    this.iconBytes,
    super.key,
  });

  Future<void> _handleAppLaunch() async {
    await LaunchApp.openApp(
      androidPackageName: packageName,
      openStore: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleAppLaunch,
      // Using buttonRadius (12.0) for internal clickable elements
      borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              // Using a subtle tint of the category color
              color: categoryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
            ),
            child: Center(
              child: iconBytes != null && iconBytes!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        iconBytes!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.apps, color: categoryColor, size: 26),
                      ),
                    )
                  : Icon(Icons.apps, color: categoryColor, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 55,
            child: Text(
              appName.split(' ').first,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}