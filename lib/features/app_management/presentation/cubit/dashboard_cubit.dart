import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  // UPDATED: Added categoryFilter parameter
  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      final apps = await repository.getInstalledApps();

      Duration totalUsage = Duration.zero;
      for (var app in apps) {
        totalUsage += app.usageDuration;
      }

      final Map<String, Duration> categoryUsage = {};
      for (var app in apps) {
        final category = app.assignedCategoryName ?? 'Uncategorized';
        categoryUsage[category] = (categoryUsage[category] ?? Duration.zero) + app.usageDuration;
      }

      String topCategory = 'None';
      Duration topDuration = Duration.zero;
      categoryUsage.forEach((key, value) {
        if (value > topDuration) {
          topDuration = value;
          topCategory = key;
        }
      });

      String insight = "You've used your phone for ${totalUsage.inMinutes}m today.";
      if (topCategory != 'None' && topDuration.inMinutes > 0) {
        insight += " Most time spent in $topCategory (${topDuration.inMinutes}m).";
      }

      // UPDATED: Filtering recommendations if a filter exists
      List<InstalledApp> recommended;
      String recMessage = "Your most used apps today:";

      if (categoryFilter != null) {
        recommended = apps.where((a) => a.assignedCategoryName == categoryFilter).toList();
        recMessage = "Switch to these $categoryFilter apps:";
      } else {
        final sortedApps = List<InstalledApp>.from(apps);
        sortedApps.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedApps.take(4).toList();
      }

      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'User', 
        totalScreenTime: totalUsage,
        mostUsedCategory: topCategory,
        recommendedApps: recommended,
        insightMessage: insight,
        recommendationMessage: recMessage,
      ));

    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        insightMessage: "Error loading data: $e"
      ));
    }
  }
}