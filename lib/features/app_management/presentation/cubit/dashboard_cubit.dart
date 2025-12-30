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
  /// If null, the logic dynamically picks a "Swap" category.
  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch apps and categories
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();

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

      // 6. Recommendation Logic (Dynamic Swap)
      List<InstalledApp> recommended = [];
      String recMessage = "";

      // Logic: If we have a specific filter (e.g. from notification), use it.
      // Otherwise, pick a category that is NOT the top used one.
      String? targetCategory = categoryFilter;

      if (targetCategory == null && userCategories.isNotEmpty) {
        // Find categories that aren't the one currently being overused
        final otherCategories = userCategories
            .map((e) => e.name)
            .where((name) => name != topCategory)
            .toList();
        
        if (otherCategories.isNotEmpty) {
          // Pick a random alternative category to keep it fresh
          targetCategory = otherCategories[Random().nextInt(otherCategories.length)];
        }
      }

      if (targetCategory != null) {
        recommended = apps.where((app) => app.assignedCategoryName == targetCategory).toList();
        
        if (recommended.isNotEmpty) {
          recMessage = "Switch to your $targetCategory apps:";
        }
      }

      // 7. Fallback: If no categorized recommendations found, show most used
      if (recommended.isEmpty) {
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