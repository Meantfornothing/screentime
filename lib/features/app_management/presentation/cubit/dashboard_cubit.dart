import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'dashboard_state.dart';
import 'dart:math';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  /// Loads dashboard data.
  /// [categoryFilter] can be passed manually (e.g. from a notification).
  /// If null, the logic dynamically picks a "Swap" category from the user's settings.
  Future<void> loadDashboardData({String? categoryFilter}) async {
    // Start by showing the loading state
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch apps and user categories from the repository
      // This includes the "Hydration" step where icons are attached live
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();

      // 2. Calculate Total Screen Time Usage
      Duration totalUsage = Duration.zero;
      for (var app in apps) {
        totalUsage += app.usageDuration;
      }

      // 3. Aggregate Usage by Category
      final Map<String, Duration> categoryUsage = {};
      for (var app in apps) {
        final category = app.assignedCategoryName ?? 'Uncategorized';
        categoryUsage[category] = (categoryUsage[category] ?? Duration.zero) + app.usageDuration;
      }

      // 4. Identify the Top-Used Category
      String topCategory = 'None';
      Duration topDuration = Duration.zero;
      categoryUsage.forEach((key, value) {
        if (value > topDuration) {
          topDuration = value;
          topCategory = key;
        }
      });

      // 5. Build the Dynamic Insight Message
      String insight = "You've used your phone for ${totalUsage.inMinutes}m today.";
      if (topCategory != 'None' && topDuration.inMinutes > 0) {
        insight += " Most time spent in $topCategory (${topDuration.inMinutes}m).";
      } else if (totalUsage.inMinutes == 0) {
        insight = "No usage data yet. Categorize apps to see detailed insights!";
      }

      // 6. Recommendation Logic (Dynamic Swap)
      List<InstalledApp> recommended = [];
      String recMessage = "";
      String? targetCategory = categoryFilter;

      // If no specific filter is provided, pick a category that is NOT being overused
      if (targetCategory == null && userCategories.isNotEmpty) {
        final otherCategories = userCategories
            .map((e) => e.name)
            .where((name) => name != topCategory)
            .toList();
        
        if (otherCategories.isNotEmpty) {
          // Pick a random alternative category from the user's own list
          targetCategory = otherCategories[Random().nextInt(otherCategories.length)];
        }
      }

      if (targetCategory != null) {
        recommended = apps.where((app) => app.assignedCategoryName == targetCategory).toList();
        if (recommended.isNotEmpty) {
          recMessage = "Switch to your $targetCategory apps:";
        }
      }

      // Fallback: If no proactive recommendation is found, show the user's most used apps
      if (recommended.isEmpty) {
        final sortedAppsByUsage = List<InstalledApp>.from(apps);
        sortedAppsByUsage.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedAppsByUsage.take(5).toList();
        recMessage = "Your most used apps today:";
      }

      // 7. Emit success state with all populated data
      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'User', 
        totalScreenTime: totalUsage,
        mostUsedCategory: topCategory,
        recommendedApps: recommended,
        allApps: apps, // Required for the Detailed Usage screen
        insightMessage: insight,
        recommendationMessage: recMessage,
      ));

    } catch (e) {
      // Handle failures gracefully
      emit(state.copyWith(
        status: DashboardStatus.failure,
        insightMessage: "Error loading data: ${e.toString()}"
      ));
    }
  }
}