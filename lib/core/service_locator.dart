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

void init() { 
  // 1. Data Sources
  sl.registerLazySingleton<CategorizationLocalDataSource>(
    () => CategorizationLocalDataSourceImpl(
      categoryBox: Hive.box<AppCategoryEntity>('categories'),
      appBox: Hive.box<InstalledApp>('installed_apps'),
    ),
  );

  sl.registerLazySingleton<InstalledAppsDataSource>(
    () => InstalledAppsDataSourceImpl(),
  );

  sl.registerLazySingleton<AppUsageDataSource>(
    () => AppUsageDataSourceImpl(),
  );

  // 2. Repositories
  sl.registerLazySingleton<CategorizationRepository>(
    () => CategorizationRepositoryImpl(
      localDataSource: sl(), 
      installedAppsDataSource: sl(),
      appUsageDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      Hive.box<UserSettingsEntity>('settings'),
    ),
  );


  // 3. Cubits
  sl.registerFactory(
    () => CategorizationCubit(sl()),
  );

  sl.registerFactory(
    () => SettingsCubit(sl()),
  );

  // NEW: Register Dashboard Cubit
  sl.registerFactory(
    () => DashboardCubit(sl()), // Injects CategorizationRepository
  );

  print("Service Locator initialized successfully.");
}