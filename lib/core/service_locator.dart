import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// Feature Imports - Entities
import '../features/app_management/domain/entities/app_category_entity.dart';
import '../features/app_management/domain/entities/installed_app_entity.dart';
import '../features/app_management/domain/entities/user_settings_entity.dart';

// Feature Imports - Repositories
import '../features/app_management/domain/repositories/categorization_repository_interface.dart';
import '../features/app_management/data/repositories/categorization_repository_impl.dart';
import '../features/app_management/domain/repositories/settings_repository_interface.dart';
import '../features/app_management/data/repositories/settings_repository_impl.dart';

// Feature Imports - Presentation
import '../features/app_management/presentation/cubit/categorization_cubit.dart';
import '../features/app_management/presentation/cubit/settings_cubit.dart';
import '../features/app_management/presentation/cubit/dashboard_cubit.dart';

// Feature Imports - Real Data Sources
import '../features/app_management/data/datasources/categorization_local_data_source.dart';
import '../features/app_management/data/datasources/installed_apps_data_source.dart';
import '../features/app_management/data/datasources/app_usage_local_data_source.dart';

// Feature Imports - Mock Data Sources
import '../features/app_management/data/datasources/mock_app_usage_data_source.dart';
import '../features/app_management/data/datasources/mock_categorization_data_source.dart';
import '../features/app_management/data/datasources/mock_installed_apps_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- CONFIGURATION FLAG ---
  // Set this to true for presentations/fictional users, false for real device data.
  const bool useMockData = true; 

  // 1. Register Adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AppCategoryEntityAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(InstalledAppAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserSettingsEntityAdapter());

  // 2. Open Boxes
  final categoryBox = await Hive.openBox<AppCategoryEntity>('categories');
  final appBox = await Hive.openBox<InstalledApp>('installed_apps');
  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');

  // 3. Data Sources (Conditional Registration)
  if (useMockData) {
    // Register Mock Implementations
    sl.registerLazySingleton<CategorizationLocalDataSource>(
      () => MockCategorizationLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<InstalledAppsDataSource>(
      () => MockInstalledAppsDataSourceImpl(),
    );
    sl.registerLazySingleton<AppUsageDataSource>(
      () => MockAppUsageDataSourceImpl(),
    );
    if (settingsBox.isEmpty) {
    await settingsBox.put('current_settings', UserSettingsEntity(
      userGoal: 'Improve Sleep',
      dailyScreenTimeGoalMinutes: 120,
      breakReminderFrequency: 0.5,
      nudgeIntensity: 0.8,
      bedtimeHour: 22,
      bedtimeMinute: 30,
    ));
  }

  } else {
    // Register Real Implementations
    sl.registerLazySingleton<CategorizationLocalDataSource>(
      () => CategorizationLocalDataSourceImpl(
        categoryBox: categoryBox,
        appBox: appBox,
      ),
    );
    sl.registerLazySingleton<InstalledAppsDataSource>(
      () => InstalledAppsDataSourceImpl(),
    );
    sl.registerLazySingleton<AppUsageDataSource>(
      () => AppUsageDataSourceImpl(),
    );
  }

  // 4. Repositories
  // These automatically pick up the correct Data Source from sl() above
  sl.registerLazySingleton<CategorizationRepository>(
    () => CategorizationRepositoryImpl(
      localDataSource: sl(), 
      installedAppsDataSource: sl(),
      appUsageDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(settingsBox),
  );

  // 5. Cubits
  sl.registerFactory(() => CategorizationCubit(sl()));
  sl.registerFactory(() => SettingsCubit(sl()));
  sl.registerFactory(() => DashboardCubit(sl()));

  print("Service Locator initialized (Mocking: $useMockData)");
}