import 'package:flutter/material.dart';
import '../../domain/entities/installed_app_entity.dart';


/// The Recommendations Card showing the message and icons of recommended apps
class RecommendationsCard extends StatelessWidget {
  final String content;
  final List<InstalledApp> recommendedApps;
  final Color Function(String categoryName) getCategoryColor; // Passed in from DashboardState
  
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
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 15),
          
          // Row of App Icons (Categorized Apps)
          Wrap(
            spacing: 16.0, 
            runSpacing: 16.0, 
            children: recommendedApps.map((app) => RecommendedAppIcon(
              appName: app.name,
              // Calculate color using the function passed from the screen
              categoryColor: getCategoryColor(app.assignedCategoryName ?? ''),
              key: ValueKey(app.packageName),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

/// Simple placeholder for an App Icon, used in the RecommendationsCard
class RecommendedAppIcon extends StatelessWidget {
  final String appName;
  final Color categoryColor;
  
  const RecommendedAppIcon({required this.appName, required this.categoryColor, super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = categoryColor.withOpacity(0.1);
    final borderColor = categoryColor.withOpacity(0.6);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(14), 
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.apps, // Use a generic placeholder icon
              color: categoryColor,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Use Flexible to prevent text overflow if the name is long
        SizedBox(
          width: 50,
          child: Text(
            appName.split(' ').first, // Show only first word of app name
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}