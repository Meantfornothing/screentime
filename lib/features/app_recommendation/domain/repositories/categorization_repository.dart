import '../entities/entities.dart';


abstract class CategorizationRepository {
  Future<List<InstalledApp>> getInstalledApps();
  Future<List<AppCategoryEntity>> getCategories();
  Future<void> addCategory(String name);
  Future<void> deleteCategory(String id);
  Future<void> assignCategory(String packageName, String categoryName);
}