import 'package:get_it/get_it.dart';

import '../features/app_recommendation/domain/repositories/categorization_repository.dart';
import '../features/app_recommendation/data/repositories/categorization_repository_impl.dart'; // Note: preserved your filename typo 'catergorization'
import '../features/app_recommendation/presentation/cubit/categorization_cubit.dart';

final sl = GetIt.instance;

void init() {
  // 1. Feature: App Recommendation
  
  // Data Layer - Repositories
  sl.registerLazySingleton<CategorizationRepository>(
    () => CategorizationRepositoryImpl(),
  );

  // Presentation Layer - Cubits
  sl.registerFactory(
    () => CategorizationCubit(sl()),
  );

  print("Service Locator initialized successfully.");
}