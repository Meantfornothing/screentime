import 'package:equatable/equatable.dart';
import '../../domain/entities/installed_app_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final String userName;
  final Duration totalScreenTime;
  final String mostUsedCategory;
  final List<InstalledApp> recommendedApps;
  final List<InstalledApp> allApps; // Ensure this field exists
  final String insightMessage;
  final String recommendationMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.userName = '',
    this.totalScreenTime = Duration.zero,
    this.mostUsedCategory = '',
    this.recommendedApps = const [],
    this.allApps = const [],
    this.insightMessage = '',
    this.recommendationMessage = '',
  });

  DashboardState copyWith({
    DashboardStatus? status,
    String? userName,
    Duration? totalScreenTime,
    String? mostUsedCategory,
    List<InstalledApp>? recommendedApps,
    List<InstalledApp>? allApps,
    String? insightMessage,
    String? recommendationMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      mostUsedCategory: mostUsedCategory ?? this.mostUsedCategory,
      recommendedApps: recommendedApps ?? this.recommendedApps,
      allApps: allApps ?? this.allApps,
      insightMessage: insightMessage ?? this.insightMessage,
      recommendationMessage: recommendationMessage ?? this.recommendationMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userName,
        totalScreenTime,
        mostUsedCategory,
        recommendedApps,
        allApps,
        insightMessage,
        recommendationMessage
      ];
}