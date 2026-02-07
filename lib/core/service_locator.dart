// lib/core/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// --- CRITICAL FIX: Use package imports exclusively to match background_service.dart ---
import 'package:screentime/features/app_management/domain/entities/app_category_entity.dart';
import 'package:screentime/features/app_management/domain/entities/installed_app_entity.dart';
import 'package:screentime/features/app_management/domain/entities/user_settings_entity.dart';

import 'package:screentime/features/app_management/domain/repositories/categorization_repository_interface.dart';
import 'package:screentime/features/app_management/data/repositories/categorization_repository_impl.dart';
import 'package:screentime/features/app_management/domain/repositories/settings_repository_interface.dart';
import 'package:screentime/features/app_management/data/repositories/settings_repository_impl.dart';

import 'package:screentime/features/app_management/presentation/cubit/categorization_cubit.dart';
import 'package:screentime/features/app_management/presentation/cubit/settings_cubit.dart';
import 'package:screentime/features/app_management/presentation/cubit/dashboard_cubit.dart';

import 'package:screentime/features/app_management/data/datasources/categorization_local_data_source.dart';
import 'package:screentime/features/app_management/data/datasources/installed_apps_data_source.dart';
import 'package:screentime/features/app_management/data/datasources/app_usage_local_data_source.dart';

import 'package:screentime/features/app_management/data/datasources/mock_app_usage_data_source.dart';
import 'package:screentime/features/app_management/data/datasources/mock_categorization_data_source.dart';
import 'package:screentime/features/app_management/data/datasources/mock_installed_apps_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- CONFIGURATION FLAG ---
  const bool useMockData = true; 

  // 1. Register Adapters
  // The class name defined in your entity file is UserSettingsEntityAdapter
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AppCategoryEntityAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(InstalledAppAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserSettingsAdapter());

  // 2. Open Boxes
  final categoryBox = await Hive.openBox<AppCategoryEntity>('categories');
  final appBox = await Hive.openBox<InstalledApp>('installed_apps');
  final settingsBox = await Hive.openBox<UserSettingsEntity>('settings');

  // 3. Data Sources (Conditional Registration)
  if (useMockData) {
    sl.registerLazySingleton<CategorizationLocalDataSource>(
      () => MockCategorizationLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<InstalledAppsDataSource>(
      () => MockInstalledAppsDataSourceImpl(),
    );
    sl.registerLazySingleton<AppUsageDataSource>(
      () => MockAppUsageDataSourceImpl(),
    );

    // Seed mock data using the new descriptive goal constants
    if (settingsBox.isEmpty) {
      await settingsBox.put('current_settings', UserSettingsEntity(
        userGoal: UserSettingsEntity.goalWorktool, // Updated to new goal constant
        dailyScreenTimeGoalMinutes: 120,
        breakReminderFrequency: 0.5,
        nudgeIntensity: 0.8,
        bedtimeHour: 22,
        bedtimeMinute: 30,
      ));
    }

  } else {
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
  
  // DashboardCubit requires both repositories for the new goal mapping logic
  sl.registerFactory(() => DashboardCubit(sl(), sl())); 

  print("Service Locator initialized (Mocking: $useMockData)");
}