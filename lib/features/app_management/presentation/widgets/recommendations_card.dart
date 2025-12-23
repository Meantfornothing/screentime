import 'dart:typed_data'; // REQUIRED
import 'package:flutter/material.dart';
import '../../domain/entities/installed_app_entity.dart';

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
          Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 16.0, 
            runSpacing: 16.0, 
            children: recommendedApps.map((app) => RecommendedAppIcon(
              appName: app.name,
              categoryColor: getCategoryColor(app.assignedCategoryName ?? ''),
              iconBytes: app.iconBytes, // Pass the bytes here
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
  final Color categoryColor;
  final Uint8List? iconBytes; // Add the bytes field
  
  const RecommendedAppIcon({
    required this.appName, 
    required this.categoryColor, 
    this.iconBytes, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14), 
            border: Border.all(color: categoryColor.withOpacity(0.6), width: 1.5),
          ),
          child: Center(
            child: iconBytes != null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(iconBytes!, width: 34, height: 34, fit: BoxFit.cover),
                  )
                : Icon(Icons.apps, color: categoryColor, size: 26),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: Text(
            appName.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}