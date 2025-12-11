import 'package:flutter/material.dart';
// Updated to use relative imports
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app.dart';

// Ensure these imports match your local widget files
import '../widgets/chart.dart'; // Assuming chart.dart is now placeholder_chart.dart
import '../widgets/insight_card.dart'; // Assuming insight_card.dart is now insights_card.dart
import '../widgets/recommendations_card.dart';

// --- Placeholder Data to match the Dashboard design ---
final String mockUserName = 'Olivia';
final String mockInsight = 'Omg did you know att du scrollar mkt? (You scroll a lot?)';
final String mockRecommendation = 'Sluta med det kanske? (Maybe stop doing that?)';

final List<AppCategoryEntity> mockDashboardCategories = [
  AppCategoryEntity(id: 'r', name: 'Relaxation'),
  AppCategoryEntity(id: 'e', name: 'Entertainment'),
  AppCategoryEntity(id: 'p', name: 'Productivity'),
];

// Mock data for the apps we want to show icons for in the Recommendation box
final List<InstalledApp> mockAppsForRecommendation = [
  InstalledApp(packageName: 'com.social.app1', name: 'Social', assignedCategoryName: 'Entertainment'),
  InstalledApp(packageName: 'com.game.app2', name: 'Game A', assignedCategoryName: 'Relaxation'),
  InstalledApp(packageName: 'com.work.app3', name: 'Work Chat', assignedCategoryName: 'Productivity'),
  InstalledApp(packageName: 'com.news.app4', name: 'News Feed', assignedCategoryName: 'Entertainment'),
];

// Map categories to colors for the legend dots (Must be public to pass to widget)
Color getCategoryColor(String name) {
  switch (name) {
    case 'Relaxation': return Colors.blue.shade600;
    case 'Entertainment': return Colors.red.shade600;
    case 'Productivity': return Colors.green.shade600;
    default: return Colors.grey;
  }
}
// ---------------------------------------------------


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: The AppBar is managed by the MainWrapper now, so we only build the body.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // Header
          Text(
            'Hi $mockUserName!',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'This is your ....blabla',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Large Visual Chart Placeholder (Mocked by an image placeholder)
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: PlaceholderChart(), // Used the correct public widget name
          ),
          const SizedBox(height: 16),

          // Category Legend Dots
          _buildCategoryLegend(),
          const SizedBox(height: 30),

          // Insights Section
          const Text(
            'Insights',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          InsightsCard(content: mockInsight),
          const SizedBox(height: 30),

          // Recommendations Section
          const Text(
            'Recommendations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          RecommendationsCard(
            content: mockRecommendation,
            recommendedApps: mockAppsForRecommendation,
            // FIX: Pass the required public function here
            getCategoryColor: getCategoryColor, 
          ),
          const SizedBox(height: 30), // Extra space above bottom nav
        ],
      ),
    );
  }

  Widget _buildCategoryLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: mockDashboardCategories.map((category) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: getCategoryColor(category.name),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.name,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      )).toList(),
    );
  }
}

// NOTE: The helper classes (AbstractShapePainter and _AppIconPlaceholder)
// MUST now be defined in their respective widget files (chart.dart, etc.).
// They are removed from here to prevent compilation errors.