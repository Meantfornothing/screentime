import 'package:get_it/get_it.dart';

// Initialize GetIt as the Service Locator instance
final sl = GetIt.instance;

/// Registers all necessary dependencies for the application.
/// This function is called once at application startup (in main.dart).
/// 
/// We use registerLazySingleton for services that need to exist throughout 
/// the app's lifetime (e.g., Repositories, Use Cases, Data Sources).
void init() { 
  // =================================================================
  // 1. Feature: App Recommendation (Placeholder for future dependencies)
  // =================================================================

  // Domain Layer - Register Use Cases:
  // sl.registerLazySingleton(() => GetNextAppRecommendation(sl()));

  // Data Layer - Register Repositories:
  // sl.registerLazySingleton<RecommendationRepository>(
  //   () => RecommendationRepositoryImpl(sl()),
  // );

  // Data Layer - Register Data Sources:
  // sl.registerLazySingleton<RecommendationLocalDataSource>(
  //   () => RecommendationLocalDataSourceImpl(),
  // );
  
  print("Service Locator initialized successfully.");
}