import 'dart:typed_data'; // REQUIRED
import 'package:flutter/material.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'package:external_app_launcher/external_app_launcher.dart'; // NEW

class RecommendationsCard extends StatelessWidget {
  final String content;
  final List<InstalledApp> recommendedApps;
  final Color Function(String categoryName) getCategoryColor;
  
  const RecommendationsCard({
    required this.content,
    required this.recommendedApps,
    required this.getCategoryColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 16.0, 
            runSpacing: 16.0, 
            children: recommendedApps.map((app) => RecommendedAppIcon(
              appName: app.name,
              packageName: app.packageName, // Make sure this exists in your entity
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

class RecommendedAppIcon extends StatelessWidget {
  final String appName;
  final String packageName;
  final Color categoryColor;
  final Uint8List? iconBytes;
  
  const RecommendedAppIcon({
    required this.appName, 
    required this.packageName, 
    required this.categoryColor, 
    this.iconBytes, 
    super.key
  });

  Future<void> _handleAppLaunch() async {
    await LaunchApp.openApp(
      androidPackageName: packageName,
      // iosUrlScheme is required if you ever port to iOS
      // Example: 'instagram://'
      openStore: true, // If app isn't found, it opens Play Store
    );
  }

    @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleAppLaunch,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54, // Slightly larger for better tap target
            height: 54,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: categoryColor.withOpacity(0.3), 
                width: 1,
              ),
            ),
            child: Center(
              // logic: If iconBytes exists, show the Image. Otherwise, show the Icon
              child: iconBytes != null && iconBytes!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        iconBytes!,
                        width: 40, 
                        height: 40,
                        fit: BoxFit.contain, // Contain ensures the icon isn't cropped awkwardly
                        // This error builder handles cases where bytes might be corrupted
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.broken_image, color: categoryColor, size: 26),
                      ),
                    )
                  : Icon(Icons.apps, color: categoryColor, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              appName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10, 
                color: Colors.black87, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}