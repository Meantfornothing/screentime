// lib/features/app_management/data/datasources/mock_categorization_data_source.dart

import 'categorization_local_data_source.dart';
import '../../domain/entities/entities.dart';

class MockCategorizationLocalDataSourceImpl implements CategorizationLocalDataSource {
  @override
  Future<List<InstalledApp>> getCachedInstalledApps() async {
    // In a mock scenario, we can just return the apps with their categories.
    // The Repository will merge these with the icons from the InstalledAppsDataSource
    // if you have that logic in your RepositoryImpl.
    return [
      InstalledApp(packageName: 'com.social.instagram', name: 'Instagram', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.social.tiktok', name: 'TikTok', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.productivity.notion', name: 'Notion', assignedCategoryName: 'Productivity'),
      InstalledApp(packageName: 'com.entertainment.netflix', name: 'Netflix', assignedCategoryName: 'Entertainment'),
    ];
  }

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    return [
      AppCategoryEntity(id: '1', name: 'Entertainment'),
      AppCategoryEntity(id: '2', name: 'Productivity'),
      AppCategoryEntity(id: '3', name: 'Social'),
    ];
  }

  // ... No-op implementations for write methods ...
  @override Future<void> addCategory(AppCategoryEntity c) async {}
  @override Future<void> deleteCategory(String id) async {}
  @override Future<void> cacheInstalledApps(List<InstalledApp> a) async {}
  @override Future<void> updateAppAssignment(String p, String c) async {}
}