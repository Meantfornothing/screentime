import '../entities/installed_app_entity.dart';
import '../entities/app_category_entity.dart';

/// The abstract contract defining operations for app categorization.
abstract class CategorizationRepository {
  /// Fetches installed apps. [forceRefresh] allows bypassing cache to scan the OS.
  Future<List<InstalledApp>> getInstalledApps({bool forceRefresh = false});

  /// Retrieves the list of defined app categories.
  Future<List<AppCategoryEntity>> getCategories();

  /// Adds a new category. Accepts the full [AppCategoryEntity] object.
  Future<void> addCategory(AppCategoryEntity category);

  /// Deletes a category by its unique ID.
  Future<void> deleteCategory(String id);

  /// Assigns an app to a category.
  Future<void> assignCategory(String packageName, String categoryName);
}