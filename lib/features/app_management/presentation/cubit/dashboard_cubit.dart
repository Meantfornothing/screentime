import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import 'dashboard_state.dart';
import '../../domain/entities/installed_app_entity.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch apps with real usage data
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
      if (topCategory != 'None') {
        insight += " Most time spent in $topCategory.";
      }

      // 5. Generate Recommendations (Simple Logic)
      // Example: Recommend apps from a different category than the top one
      // Or just show apps with low usage (Productivity?)
      
      List<InstalledApp> recommendations = [];
      if (topCategory == 'Entertainment') {
        // Recommend Productivity apps
        recommendations = apps.where((app) => app.assignedCategoryName == 'Productivity').take(4).toList();
      } else {
        // Recommend Entertainment apps (mock logic for balance)
        recommendations = apps.where((app) => app.assignedCategoryName == 'Entertainment').take(4).toList();
      }
      
      // Fallback if empty
      if (recommendations.isEmpty) {
        recommendations = apps.take(4).toList();
      }

      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'Olivia', // Could be fetched from UserSettings later
        totalScreenTime: totalUsage,
        mostUsedCategory: topCategory,
        recommendedApps: recommendations,
        insightMessage: insight,
        recommendationMessage: recommendations.isNotEmpty 
            ? "Try balancing your time with these:" 
            : "Categorize more apps to get recommendations!",
      ));

    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.failure));
    }
  }
}