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
  // 1. Get metadata (PackageNames/Categories) from Hive
  List<InstalledApp> cachedApps = await localDataSource.getCachedInstalledApps();
  
  // 2. Always fetch fresh icons from the OS
  // (MethodChannel is fast enough for this)
  final osApps = await installedAppsDataSource.getInstalledAppsFromOS();

  if (cachedApps.isEmpty || forceRefresh) {
    await localDataSource.cacheInstalledApps(osApps);
    cachedApps = osApps;
  }

  // 3. THE FIX: Merge (Hydrate) the icons into your cached list
  final List<InstalledApp> appsWithIcons = cachedApps.map((cachedApp) {
    // Find the corresponding app from the OS fetch to get its icon
    final osApp = osApps.firstWhere(
      (os) => os.packageName == cachedApp.packageName,
      orElse: () => osApps.first,
    );

    return cachedApp.copyWith(
      iconBytes: osApp.iconBytes, // Attach the fresh icon bytes here
    );
  }).toList();

  // 4. Attach usage duration and return
  final usageMap = await appUsageDataSource.getDailyUsage();
  return appsWithIcons.map((app) {
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