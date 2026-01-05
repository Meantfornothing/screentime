import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// Feature Imports - Entities
import '../features/app_management/domain/entities/app_category_entity.dart';
import '../features/app_management/domain/entities/installed_app_entity.dart';
import '../features/app_management/domain/entities/user_settings_entity.dart'; // Ensure imported

// Feature Imports - Repositories
import '../features/app_management/domain/repositories/categorization_repository_interface.dart';
import '../features/app_management/data/repositories/categorization_repository_impl.dart';
import '../features/app_management/domain/repositories/settings_repository_interface.dart'; // Import Settings interface
import '../features/app_management/data/repositories/settings_repository_impl.dart'; // Import Settings impl

// Feature Imports - Presentation
import '../features/app_management/presentation/cubit/categorization_cubit.dart';
import '../features/app_management/presentation/cubit/settings_cubit.dart';
import '../features/app_management/presentation/cubit/dashboard_cubit.dart'; // NEW

// Feature Imports - Data Sources
import '../features/app_management/data/datasources/categorization_local_data_source.dart';
import '../features/app_management/data/datasources/installed_apps_data_source.dart';
import '../features/app_management/data/datasources/app_usage_local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Register Adapters first
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AppCategoryEntityAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(InstalledAppAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserSettingsEntityAdapter());

  // 2. Open Boxes (This MUST be awaited before they are used)
  final categoryBox = await Hive.openBox<AppCategoryEntity>('categories');
  final appBox = await Hive.openBox<InstalledApp>('installed_apps');
  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');

  // 3. Data Sources - Pass the opened boxes directly
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

  // 4. Repositories
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

  print("Service Locator initialized successfully.");
}