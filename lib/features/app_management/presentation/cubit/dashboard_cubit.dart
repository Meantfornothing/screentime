import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch apps (Repo automatically fetches Usage stats and merges them!)
      final apps = await repository.getInstalledApps();

      // 2. Calculate Total Usage
      Duration totalUsage = Duration.zero;
      for (var app in apps) {
        totalUsage += app.usageDuration;
      }

      // 3. Find Most Used Category
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

      // 4. Generate Insights
      String insight = "You've used your phone for ${totalUsage.inMinutes}m today.";
      if (topCategory != 'None' && topDuration.inMinutes > 0) {
        insight += " Most time spent in $topCategory (${topDuration.inMinutes}m).";
      } else if (totalUsage.inMinutes == 0) {
        insight = "No usage data yet. Grant permissions or use your phone!";
      }

      // 5. Recommendations: Show "Top Used Apps"
      final sortedApps = List<InstalledApp>.from(apps);
      sortedApps.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
      final topApps = sortedApps.take(4).toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'User', 
        totalScreenTime: totalUsage,
        mostUsedCategory: topCategory,
        recommendedApps: topApps,
        insightMessage: insight,
        recommendationMessage: "Your most used apps today:",
      ));

    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        insightMessage: "Error loading data: $e"
      ));
    }
  }
}