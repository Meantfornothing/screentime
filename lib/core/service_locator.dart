import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../features/app_management/domain/entities/entities.dart';
import '../../features/app_management/domain/repositories/categorization_repository_interface.dart';
import '../../features/app_management/data/repositories/categorization_repository_impl.dart';
import '../features/app_management/domain/repositories/settings_repository_interface.dart';
import '../features/app_management/data/repositories/settings_repository_impl.dart';
import '../features/app_management/presentation/cubit/settings_cubit.dart';
import '../../features/app_management/presentation/cubit/categorization_cubit.dart';

import '../../features/app_management/data/datasources/categorization_local_data_source.dart';
import '../../features/app_management/data/datasources/installed_apps_data_source.dart';
import '../../features/app_management/data/datasources/app_usage_local_data_source.dart'; // Import

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

  // Register New Usage Source
  sl.registerLazySingleton<AppUsageDataSource>(
    () => AppUsageDataSourceImpl(),
  );

  // 2. Repositories
  sl.registerLazySingleton<CategorizationRepository>(
    () => CategorizationRepositoryImpl(
      localDataSource: sl(), 
      installedAppsDataSource: sl(),
      appUsageDataSource: sl(), // Inject
    ),
  );

  // 3. Cubits
  sl.registerFactory(
    () => CategorizationCubit(sl()),
  );
  // Settings Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(Hive.box<UserSettingsEntity>('settings')),
  );

  // Settings Cubit
  sl.registerFactory(
    () => SettingsCubit(sl()),
  );

  print("Service Locator initialized successfully.");
}