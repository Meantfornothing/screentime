import 'package:hive/hive.dart';
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app_entity.dart';

abstract class CategorizationLocalDataSource {
  Future<List<AppCategoryEntity>> getCategories();
  Future<void> addCategory(AppCategoryEntity category);
  Future<void> deleteCategory(String id);
  
  Future<List<InstalledApp>> getCachedInstalledApps();
  Future<void> cacheInstalledApps(List<InstalledApp> apps);
  Future<void> updateAppAssignment(String packageName, String categoryName);
}

class CategorizationLocalDataSourceImpl implements CategorizationLocalDataSource {
  final Box<AppCategoryEntity> categoryBox;
  final Box<InstalledApp> appBox;

  CategorizationLocalDataSourceImpl({
    required this.categoryBox,
    required this.appBox,
  });

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    if (categoryBox.isEmpty) {
      // Seed initial default categories if empty
      final defaults = [
        AppCategoryEntity(id: '1', name: 'Entertainment'),
        AppCategoryEntity(id: '2', name: 'Productivity'),
        AppCategoryEntity(id: '3', name: 'Neutral'),
      ];
      await categoryBox.addAll(defaults);
      return defaults;
    }
    return categoryBox.values.toList();
  }

  @override
  Future<void> addCategory(AppCategoryEntity category) async {
    await categoryBox.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Find the key (index) associated with this ID since Hive stores by key
    final map = categoryBox.toMap();
    final key = map.keys.firstWhere((k) => map[k]?.id == id, orElse: () => null);
    if (key != null) {
      await categoryBox.delete(key);
    }
  }

  @override
  Future<List<InstalledApp>> getCachedInstalledApps() async {
    return appBox.values.toList();
  }

  @override
  Future<void> cacheInstalledApps(List<InstalledApp> apps) async {
    // Clear and re-add or upsert. For simplicity, let's clear and add.
    // In a real app, you'd want to merge so you don't lose assignments.
    // Here we assume assignments are part of the 'apps' list passed in or merged in Repo.
    
    // For this simple implementation, we just put them.
    for (var app in apps) {
      await appBox.put(app.packageName, app);
    }
  }

  @override
  Future<void> updateAppAssignment(String packageName, String categoryName) async {
    final app = appBox.get(packageName);
    if (app != null) {
      final updatedApp = InstalledApp(
        packageName: app.packageName, 
        name: app.name, 
        assignedCategoryName: categoryName
      );
      await appBox.put(packageName, updatedApp);
    }
  }
}