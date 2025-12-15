
import '../../domain/entities/entities.dart';

enum CategorizationStatus { initial, loading, success, failure }

class CategorizationState {
  final CategorizationStatus status;
  final List<InstalledApp> apps;
  final List<AppCategoryEntity> categories;
  final String? errorMessage;

  const CategorizationState({
    this.status = CategorizationStatus.initial,
    this.apps = const [],
    this.categories = const [],
    this.errorMessage,
  });

  CategorizationState copyWith({
    CategorizationStatus? status,
    List<InstalledApp>? apps,
    List<AppCategoryEntity>? categories,
    String? errorMessage,
  }) {
    return CategorizationState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}