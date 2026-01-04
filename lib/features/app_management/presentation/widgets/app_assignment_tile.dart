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
    // - Using functional colors from AppColors
    Color chipColor = app.assignedCategoryName != null 
        ? AppColors.success.withOpacity(0.1) 
        : Colors.grey.shade200;
        
    Color textColor = app.assignedCategoryName != null 
        ? AppColors.success 
        : AppColors.textSecondary;

    // Mapping colors for known categories
    if (app.assignedCategoryName == 'Productivity') {
      chipColor = AppColors.primary.withOpacity(0.1); 
      textColor = AppColors.primaryVariant;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.background, // - Replaced Colors.white
          borderRadius: AppShapes.cardBorder, // - Replaced BorderRadius.circular(12)
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)), //
        ),
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (app.iconBytes != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.memory(app.iconBytes!, width: 32, height: 32),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.android, size: 32, color: AppColors.textSecondary), //
              ),
            Expanded(
              child: Text(
                app.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16, 
                  color: AppColors.textPrimary, // - Replaced Colors.black87
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            GestureDetector(
              onTap: () => _showCategorySelection(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20), // Pill shape preserved
                ),
                child: Row(
                  children: [
                    Text(
                      app.assignedCategoryName ?? 'Uncategorized',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
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