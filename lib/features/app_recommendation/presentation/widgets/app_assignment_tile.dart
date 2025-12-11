import 'package:flutter/material.dart';
import 'package:screentime/features/app_recommendation/domain/entities/installed_app.dart';
import 'package:screentime/features/app_recommendation/domain/entities/app_category_entity.dart';
// Import models needed by this widget

/// Replicates the list tile for assigning a category to an app (Bottom section).
class AppAssignmentTile extends StatelessWidget {
  final InstalledApp app;
  final Function(String category) onAssignCategory;
  final List<AppCategoryEntity> availableCategories;

  const AppAssignmentTile({
    required this.app,
    required this.onAssignCategory,
    required this.availableCategories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color for the assigned category chip based on mock data
    // In a real app, this would use a color map based on the category name.
    Color chipColor = app.assignedCategoryName == 'Productivity' ? Colors.green.shade100 : Colors.orange.shade100;
    Color textColor = app.assignedCategoryName == 'Productivity' ? Colors.green.shade800 : Colors.orange.shade800;

    // Handle null case for uncategorized apps visually
    if (app.assignedCategoryName == null) {
      chipColor = Colors.grey.shade200;
      textColor = Colors.black54;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Name (Application A, B, C...)
            Text(
              app.name,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            
            // Category Chip and Dropdown
            GestureDetector(
              onTap: () => _showCategorySelection(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      app.assignedCategoryName ?? 'Uncategorized',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    const Icon(Icons.keyboard_arrow_left, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show category selection options
  void _showCategorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assign Category:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...availableCategories.map((category) => ListTile(
                title: Text(category.name),
                onTap: () {
                  onAssignCategory(category.name);
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}