import '../entities/installed_app_entity.dart';
import '../entities/app_category_entity.dart';

abstract class CategorizationRepository {
  // Added forceRefresh parameter
  Future<List<InstalledApp>> getInstalledApps({bool forceRefresh = false});

  Future<List<AppCategoryEntity>> getCategories();

  // Changed parameter type from String to AppCategoryEntity
  Future<void> addCategory(AppCategoryEntity category);

  Future<void> deleteCategory(String id);

  Future<void> assignCategory(String packageName, String categoryName);
}