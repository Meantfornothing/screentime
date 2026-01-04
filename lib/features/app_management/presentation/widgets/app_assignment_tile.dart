import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart'; // - Updated import path
import '../../domain/entities/entities.dart';

class AppAssignmentTile extends StatelessWidget {
  final InstalledApp app;
  final Function(String categoryName) onAssignCategory;
  final Function(String newCategoryName) onAddNewCategory;
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
    // 1. Get the dynamic color based on the category name
    final String categoryName = app.assignedCategoryName ?? 'Uncategorized';
    final Color categoryColor = AppColors.getCategoryColor(categoryName);

    // 2. Define the styling based on the retrieved category color
    final Color chipColor = categoryColor.withOpacity(0.12);
    final Color textColor = categoryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 56, // Increased slightly for better tap target
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppShapes.cardBorder, 
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)), 
        ),
        padding: const EdgeInsets.only(left: 15, right: 8),
        child: Row(
          children: [
            // App Icon
            if (app.iconBytes != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.memory(app.iconBytes!, width: 32, height: 32),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.apps, size: 32, color: AppColors.textSecondary),
              ),
            
            // App Name
            Expanded(
              child: Text(
                app.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16, 
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Dynamic Category Chip
            GestureDetector(
              onTap: () => _showCategorySelection(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 13, 
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.cardRadius)), //
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
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary, // - Replaced hex color
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Create New Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: AppColors.primary, //
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAddCategoryDialog(context);
                },
              ),
              const Divider(),

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = availableCategories[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: app.assignedCategoryName == category.name 
                          ? const Icon(Icons.check, color: AppColors.success) //
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
            decoration: const InputDecoration(
              hintText: 'Category Name',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary), //
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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