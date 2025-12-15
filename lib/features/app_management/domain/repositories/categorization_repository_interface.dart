import '../entities/app_category_entity.dart';
import '../entities/installed_app_entity.dart'; // FIX: Import renamed file

abstract class CategorizationRepository {
  // FIX: Return type must be InstalledAppEntity
  Future<List<InstalledApp>> getInstalledApps();
  
  Future<List<AppCategoryEntity>> getCategories();
  Future<void> addCategory(String name);
  Future<void> deleteCategory(String id);
  Future<void> assignCategory(String packageName, String categoryName);
}