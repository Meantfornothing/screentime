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
    // Returnerar endast de fem tillåtna kategorierna
    return [
      AppCategoryEntity(id: '1', name: 'Entertainment'),
      AppCategoryEntity(id: '2', name: 'Social'),
      AppCategoryEntity(id: '3', name: 'Productivity'),
      AppCategoryEntity(id: '4', name: 'Relaxation'),
      AppCategoryEntity(id: '5', name: 'Neutral'),
    ];
  }

  @override
  Future<void> updateAppAssignment(String packageName, String categoryName) async {
    final app = appBox.get(packageName);
    if (app != null) {
      final updatedApp = InstalledApp(
        packageName: app.packageName, 
        name: app.name, 
        assignedCategoryName: categoryName.isEmpty ? 'Neutral' : categoryName
      );
      await appBox.put(packageName, updatedApp);
    }
  }

  @override
  Future<List<InstalledApp>> getCachedInstalledApps() async {
    return appBox.values.toList();
  }

  @override
  Future<void> cacheInstalledApps(List<InstalledApp> apps) async {
    for (var app in apps) {
      await appBox.put(app.packageName, app);
    }
  }

  // Inaktiverade då användaren inte får ändra kategorilistan
  @override Future<void> addCategory(AppCategoryEntity category) async {}
  @override Future<void> deleteCategory(String id) async {}
}