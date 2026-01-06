// lib/features/app_management/data/datasources/mock_categorization_data_source.dart
import 'categorization_local_data_source.dart';
import '../../domain/entities/entities.dart';


class MockCategorizationLocalDataSourceImpl implements CategorizationLocalDataSource {
  @override
  Future<List<InstalledApp>> getCachedInstalledApps() async {
    return [
      InstalledApp(packageName: 'com.facebook.katana', name: 'Facebook', assignedCategoryName: 'Entertainment'),
      InstalledApp(packageName: 'com.instagram.android', name: 'Instagram', assignedCategoryName: 'Entertainment'),
      InstalledApp(packageName: 'se.svt.play', name: 'SVT Play', assignedCategoryName: 'Entertainment'),
      InstalledApp(packageName: 'com.google.android.googlequicksearchbox', name: 'Google', assignedCategoryName: 'Productivity'),
      InstalledApp(packageName: 'com.google.android.youtube', name: 'YouTube', assignedCategoryName: 'Productivity'),
      InstalledApp(packageName: 'com.facebook.orca', name: 'Messenger', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.android.server.telecom', name: 'Telefon', assignedCategoryName: 'Social'),
      InstalledApp(packageName: 'com.storytel.storytel', name: 'Storytel', assignedCategoryName: 'Relaxation'),
      InstalledApp(packageName: 'se.svd.korsord', name: 'SVD Korsord', assignedCategoryName: 'Relaxation'),
      InstalledApp(packageName: 'com.bankid.mobile', name: 'Bank-ID', assignedCategoryName: 'Neutral'),
      InstalledApp(packageName: 'se.smhi.smhi', name: 'Väder', assignedCategoryName: 'Neutral'),
    ];
  }


  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    return [
      AppCategoryEntity(id: '1', name: 'Entertainment'),
      AppCategoryEntity(id: '2', name: 'Productivity'),
      AppCategoryEntity(id: '3', name: 'Social'),
      AppCategoryEntity(id: '4', name: 'Relaxation'),
      AppCategoryEntity(id: '5', name: 'Neutral'),
    ];
  }


  @override Future<void> addCategory(AppCategoryEntity c) async {}
  @override Future<void> deleteCategory(String id) async {}
  @override Future<void> cacheInstalledApps(List<InstalledApp> a) async {}
  @override Future<void> updateAppAssignment(String p, String c) async {}
}
