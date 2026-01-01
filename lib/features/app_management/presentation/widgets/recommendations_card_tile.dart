import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import '../../domain/entities/installed_app_entity.dart';

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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
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
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: iconBytes != null && iconBytes!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        iconBytes!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
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
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}