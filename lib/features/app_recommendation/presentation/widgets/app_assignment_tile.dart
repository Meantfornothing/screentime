import 'package:flutter/material.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/entities/app_category_entity.dart';

class AppAssignmentTile extends StatelessWidget {
  final InstalledApp app;
  final Function(String categoryName) onAssignCategory;
  final Function(String newCategoryName) onAddNewCategory; // New callback
  final List<AppCategoryEntity> availableCategories;

  const AppAssignmentTile({
    required this.app,
    required this.onAssignCategory,
    required this.onAddNewCategory,
    required this.availableCategories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor = app.assignedCategoryName != null ? Colors.green.shade100 : Colors.grey.shade200;
    Color textColor = app.assignedCategoryName != null ? Colors.green.shade800 : Colors.black54;

    // Mapping colors for known categories (Optional visual enhancement)
    if (app.assignedCategoryName == 'Productivity') {
      chipColor = Colors.green.shade100; textColor = Colors.green.shade800;
    } else if (app.assignedCategoryName == 'Entertainment') {
      chipColor = Colors.red.shade100; textColor = Colors.red.shade800;
    } else if (app.assignedCategoryName == 'Relaxation') {
      chipColor = Colors.blue.shade100; textColor = Colors.blue.shade800;
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
            Expanded(
              child: Text(
                app.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            
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
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Assign Category:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              
              // 1. "Add New" Option at the top
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF98), // Brown accent
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Create New Category',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD4AF98)),
                ),
                onTap: () {
                  Navigator.pop(sheetContext); // Close sheet
                  _showAddCategoryDialog(context); // Open dialog
                },
              ),
              const Divider(),

              // 2. Existing Categories
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = availableCategories[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: app.assignedCategoryName == category.name 
                          ? const Icon(Icons.check, color: Colors.green) 
                          : null,
                      onTap: () {
                        onAssignCategory(category.name);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper dialog to create a new category directly
  void _showAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('New Category'),
          content: TextField(
            controller: textController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  onAddNewCategory(textController.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}