import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../datasources/categorization_local_data_source.dart';
import '../datasources/installed_apps_data_source.dart';
import '../datasources/app_usage_local_data_source.dart';

class CategorizationRepositoryImpl implements CategorizationRepository {
  final CategorizationLocalDataSource localDataSource;
  final InstalledAppsDataSource installedAppsDataSource;
  final AppUsageDataSource appUsageDataSource;

  CategorizationRepositoryImpl({
    required this.localDataSource,
    required this.installedAppsDataSource,
    required this.appUsageDataSource,
  });

  @override
  Future<List<InstalledApp>> getInstalledApps({bool forceRefresh = false}) async {
    List<InstalledApp> apps = await localDataSource.getCachedInstalledApps();
    
    if (forceRefresh || apps.isEmpty) {
      try {
        final osApps = await installedAppsDataSource.getInstalledAppsFromOS();
        await localDataSource.cacheInstalledApps(osApps);
        apps = osApps;
      } catch (e) {
        if (apps.isEmpty) return [];
      }
    }

    final usageMap = await appUsageDataSource.getDailyUsage();
    return apps.map((app) {
      final usage = usageMap[app.packageName] ?? Duration.zero;
      return app.copyWith(usageDuration: usage);
    }).toList();
  }

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    return localDataSource.getCategories();
  }

  @override
  Future<void> addCategory(AppCategoryEntity category) async {
    // FIX: Passing the entity directly
    await localDataSource.addCategory(category);
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