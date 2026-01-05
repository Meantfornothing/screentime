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
    // 1. Get metadata (PackageNames/Categories) from the local source (Hive or Mock)
    List<InstalledApp> cachedApps = await localDataSource.getCachedInstalledApps();
    
    // 2. Fetch fresh visual data (Icons/Names) from the OS (or Mock OS)
    // Wrapped in a try-catch to prevent asset loading errors in mock mode from crashing the app
    List<InstalledApp> osApps;
    try {
      osApps = await installedAppsDataSource.getInstalledAppsFromOS();
    } catch (e) {
      osApps = [];
      print("Warning: Could not fetch OS apps (possibly mock asset mismatch): $e");
    }

    // 3. Handle initial population or forced refresh (mostly for real device mode)
    if (cachedApps.isEmpty || forceRefresh) {
      if (osApps.isNotEmpty) {
        await localDataSource.cacheInstalledApps(osApps);
        cachedApps = osApps;
      }
    }

    // 4. DEFENSIVE MERGE: Hydrate icons into the cached list
    // This logic ensures that package names match correctly between your mock files.
    final List<InstalledApp> appsWithIcons = cachedApps.map((cachedApp) {
      // Find the corresponding app from the OS fetch to get its icon bytes.
      // We use a safe lookup to avoid calling .first on an empty list.
      final InstalledApp? osMatch = osApps.cast<InstalledApp?>().firstWhere(
        (os) => os?.packageName == cachedApp.packageName,
        orElse: () => null,
      );

      // Return cached app with the icon. If no match is found, preserve the cached icon.
      return cachedApp.copyWith(
        iconBytes: osMatch?.iconBytes ?? cachedApp.iconBytes,
      );
    }).toList();

    // 5. Attach usage duration from the usage data source (Real or Mock)
    final Map<String, Duration> usageMap = await appUsageDataSource.getDailyUsage();
    
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