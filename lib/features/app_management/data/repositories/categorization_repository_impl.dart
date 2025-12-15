import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app_entity.dart'; // Uses InstalledApp class
import '../datasources/categorization_local_data_source.dart';
import '../datasources/installed_apps_data_source.dart';
import '../datasources/app_usage_local_data_source.dart';

class CategorizationRepositoryImpl implements CategorizationRepository {
  final CategorizationLocalDataSource localDataSource;
  final InstalledAppsDataSource installedAppsDataSource;
  final AppUsageDataSource appUsageDataSource; // New Dependency

  CategorizationRepositoryImpl({
    required this.localDataSource,
    required this.installedAppsDataSource,
    required this.appUsageDataSource,
  });

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    return localDataSource.getCategories();
  }

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    // 1. Get base apps (from cache or OS)
    List<InstalledApp> apps = await localDataSource.getCachedInstalledApps();
    
    if (apps.isEmpty) {
      try {
        final osApps = await installedAppsDataSource.getInstalledAppsFromOS();
        await localDataSource.cacheInstalledApps(osApps);
        apps = osApps;
      } catch (e) {
        return [];
      }
    }

    // 2. Fetch & Merge Usage Data (Silent update)
    final usageMap = await appUsageDataSource.getDailyUsage();
    
    return apps.map((app) {
      final usage = usageMap[app.packageName] ?? Duration.zero;
      return app.copyWith(usageDuration: usage);
    }).toList();
  }

  @override
  Future<void> addCategory(String name) async {
    final newCategory = AppCategoryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name
    );
    await localDataSource.addCategory(newCategory);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<void> assignCategory(String packageName, String categoryName) async {
    await localDataSource.updateAppAssignment(packageName, categoryName);
  }
}