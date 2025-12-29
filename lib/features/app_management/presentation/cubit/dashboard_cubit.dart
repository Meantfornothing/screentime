import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  /// Loads dashboard data. Accepts an optional [categoryFilter] to handle
  /// targeted app recommendations (e.g., from a "swap" notification).
  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch apps
      final apps = await repository.getInstalledApps();

      // 2. Calculate Total Usage
      Duration totalUsage = Duration.zero;
      for (var app in apps) {
        totalUsage += app.usageDuration;
      }

      // 3. Find Category Usage
      final Map<String, Duration> categoryUsage = {};
      for (var app in apps) {
        final category = app.assignedCategoryName ?? 'Uncategorized';
        categoryUsage[category] = (categoryUsage[category] ?? Duration.zero) + app.usageDuration;
      }

      // 4. Find Most Used Category
      String topCategory = 'None';
      Duration topDuration = Duration.zero;
      categoryUsage.forEach((key, value) {
        if (value > topDuration) {
          topDuration = value;
          topCategory = key;
        }
      });

      // 5. Generate Insight Message
      String insight = "You've used your phone for ${totalUsage.inMinutes}m today.";
      if (topCategory != 'None' && topDuration.inMinutes > 0) {
        insight += " Most time spent in $topCategory (${topDuration.inMinutes}m).";
      } else if (totalUsage.inMinutes == 0) {
        insight = "No usage data yet. Start using categorized apps to see insights!";
      }

      // 6. Recommendation Logic (Swap Nudge Support)
      List<InstalledApp> recommended;
      String recMessage;

      if (categoryFilter != null) {
        // Targeted recommendations: Show apps from the target category (e.g., Entertainment)
        recommended = apps.where((app) => app.assignedCategoryName == categoryFilter).toList();
        recMessage = "Switch to these $categoryFilter apps:";
        
        // Fallback if no apps are categorized under the target
        if (recommended.isEmpty) {
          recMessage = "No apps found in '$categoryFilter'. Try these instead:";
          final sortedApps = List<InstalledApp>.from(apps);
          sortedApps.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
          recommended = sortedApps.take(5).toList();
        }
      } else {
        // Default: Show top 4 used apps
        final sortedApps = List<InstalledApp>.from(apps);
        sortedApps.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedApps.take(5).toList();
        recMessage = "Your most used apps today:";
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
        insightMessage: "Error loading data: ${e.toString()}"
      ));
    }
  }
}