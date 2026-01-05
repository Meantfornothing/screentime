import 'package:equatable/equatable.dart';
import '../../domain/entities/installed_app_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final String userName;
  final Duration totalScreenTime;
  final String mostUsedCategory;
  final List<InstalledApp> recommendedApps;
  final List<InstalledApp> allApps;
  final String insightMessage;
  final String recommendationMessage;
  
  // Nya fält för AI-genererad visualisering
  final String? aiImageUrl;
  final bool isGeneratingImage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.userName = '',
    this.totalScreenTime = Duration.zero,
    this.mostUsedCategory = '',
    this.recommendedApps = const [],
    this.allApps = const [],
    this.insightMessage = '',
    this.recommendationMessage = '',
    this.aiImageUrl,
    this.isGeneratingImage = false,
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
    String? aiImageUrl,
    bool? isGeneratingImage,
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
      aiImageUrl: aiImageUrl ?? this.aiImageUrl,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
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
        recommendationMessage,
        aiImageUrl,
        isGeneratingImage,
      ];
}
/// och `isGeneratingImage` i `props` säkerställer att UI:t reagerar korrekt när bildens status ändras.