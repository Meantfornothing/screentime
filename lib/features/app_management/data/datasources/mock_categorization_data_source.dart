// lib/features/app_management/data/datasources/mock_categorization_data_source.dart

import 'categorization_local_data_source.dart';
import '../../domain/entities/entities.dart';

class MockCategorizationLocalDataSourceImpl implements CategorizationLocalDataSource {
  @override
  Future<List<InstalledApp>> getCachedInstalledApps() async {
    // Returnerar mock-appar med de nya fasta kategorierna.
    // Appar som inte har en tydlig kategori får "Neutral".
    return [
      InstalledApp(packageName: 'com.social.instagram', name: 'Instagram', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.social.tiktok', name: 'TikTok', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.productivity.notion', name: 'Notion', assignedCategoryName: 'Productivity'),
      InstalledApp(packageName: 'com.entertainment.netflix', name: 'Netflix', assignedCategoryName: 'Entertainment'),
      // Exempel på en app som hamnar i den nya Relaxation-kategorin
      InstalledApp(packageName: 'com.relax.calm', name: 'Calm', assignedCategoryName: 'Relaxation'),
      // App utan specifik kategori blir Neutral
      InstalledApp(packageName: 'com.android.settings', name: 'Settings', assignedCategoryName: 'Neutral'),
    ];
  }

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    // Matchar den fasta listan i din riktiga implementation
    return [
      AppCategoryEntity(id: '1', name: 'Entertainment'),
      AppCategoryEntity(id: '2', name: 'Social'),
      AppCategoryEntity(id: '3', name: 'Productivity'),
      AppCategoryEntity(id: '4', name: 'Relaxation'),
      AppCategoryEntity(id: '5', name: 'Neutral'),
    ];
  }

  // Inaktiverade metoder för att förhindra ändringar i den fasta listan
  @override 
  Future<void> updateAppAssignment(String packageName, String categoryName) async {
    // I en mock kan vi lämna denna tom eller printa för debug
    print("Mock: Uppdaterar $packageName till ${categoryName.isEmpty ? 'Neutral' : categoryName}");
  }

  @override Future<void> addCategory(AppCategoryEntity c) async {}
  @override Future<void> deleteCategory(String id) async {}
  @override Future<void> cacheInstalledApps(List<InstalledApp> a) async {}
}