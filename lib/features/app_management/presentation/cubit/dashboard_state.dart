import '../../domain/entities/installed_app_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState {
  final DashboardStatus status;
  final String userName;
  final Duration totalScreenTime;
  final String mostUsedCategory;
  final List<InstalledApp> recommendedApps;
  final String insightMessage;
  final String recommendationMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.userName = 'User',
    this.totalScreenTime = Duration.zero,
    this.mostUsedCategory = 'None',
    this.recommendedApps = const [],
    this.insightMessage = 'Loading insights...',
    this.recommendationMessage = 'Loading recommendations...',
  });

  DashboardState copyWith({
    DashboardStatus? status,
    String? userName,
    Duration? totalScreenTime,
    String? mostUsedCategory,
    List<InstalledApp>? recommendedApps,
    String? insightMessage,
    String? recommendationMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      mostUsedCategory: mostUsedCategory ?? this.mostUsedCategory,
      recommendedApps: recommendedApps ?? this.recommendedApps,
      insightMessage: insightMessage ?? this.insightMessage,
      recommendationMessage: recommendationMessage ?? this.recommendationMessage,
    );
  }
}