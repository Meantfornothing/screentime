// lib/features/app_management/presentation/cubit/dashboard_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_usage/app_usage.dart'; // Import this to handle the permission check
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/repositories/settings_repository_interface.dart'; 
import '../../domain/entities/user_settings_entity.dart'; 
import '../../domain/entities/installed_app_entity.dart';
import '../../../../core/services/gemini_service.dart';
import 'dashboard_state.dart';
import 'dart:math';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;
  final SettingsRepository settingsRepository; 

  DashboardCubit(this.repository, this.settingsRepository) : super(const DashboardState());

  /// New helper method to trigger the system prompt if permission is missing
// Inside DashboardCubit class:

  Future<void> ensureSystemPermissions() async {
    try {
      // This call forces Android to check for Usage Access.
      // If it's missing, the app_usage package attempts to open the system settings.
      await AppUsage().getAppUsage(
        DateTime.now().subtract(const Duration(seconds: 1)), 
        DateTime.now()
      );
    } catch (e) {
      // If the package doesn't auto-redirect, you'll see the error here
      print("Redirecting to system settings: $e");
    }
  }

  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch data from repositories
      // If permission is missing, this call usually throws an Exception
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();
      final settings = await settingsRepository.getSettings();

      // ... [rest of your logic remains the same] ...
      Duration totalUsage = Duration.zero;
      final Map<String, Duration> categoryUsage = {};
      
      for (var app in apps) {
        totalUsage += app.usageDuration;
        final category = app.assignedCategoryName ?? 'Neutral';
        categoryUsage[category] = (categoryUsage[category] ?? Duration.zero) + app.usageDuration;
      }

      // 2. Handling 0 minutes / Permission Missing logic
      final Map<String, int> percentages = {};
      
      // If apps are returned but total is 0, it might be the first start
      String insight = totalUsage.inMinutes == 0 
          ? "No usage data yet. Grant permission or use your phone to see insights!" 
          : "You've used your phone for ${totalUsage.inMinutes}m today.";

      if (totalUsage.inMinutes > 0) {
        categoryUsage.forEach((cat, duration) {
          percentages[cat] = ((duration.inMinutes / totalUsage.inMinutes) * 100).round();
        });

        final aiInsight = await GeminiService.generateInsightMessage(
          userGoal: settings.userGoal,
          categoryPercentages: percentages,
        );
        if (aiInsight != null) insight = aiInsight;
      }

      // 3. Goal-Based Recommendation Logic (unchanged)
      // ... [your existing switch and filtering logic] ...
      String topCategory = 'None';
      Duration topDuration = Duration.zero;
      categoryUsage.forEach((key, value) {
        if (value > topDuration) {
          topDuration = value;
          topCategory = key;
        }
      });
      
      List<InstalledApp> recommended = [];
      String recMessage = "";
      String? targetCategory = categoryFilter;
      if (targetCategory == null) {
        switch (settings.userGoal) {
          case UserSettingsEntity.goalWorktool:
          case UserSettingsEntity.goalProductivePrecedence:
            targetCategory = 'Productivity';
            recMessage = "Stay focused! Use these tools:";
            break;
          case UserSettingsEntity.goalSocial:
            targetCategory = 'Social';
            recMessage = "Connect with your people:";
            break;
          case UserSettingsEntity.goalEntertainment:
            targetCategory = 'Entertainment';
            recMessage = "Ready for a break? Try these:";
            break;
          case UserSettingsEntity.goalRelaxingContent:
          case UserSettingsEntity.goalReduceStress:
            targetCategory = 'Relaxation'; 
            recMessage = "Breathe and unwind:";
            break;
          default:
            final otherCategories = userCategories.map((e) => e.name).where((n) => n != topCategory).toList();
            if (otherCategories.isNotEmpty) {
              targetCategory = otherCategories[Random().nextInt(otherCategories.length)];
              recMessage = "Switch to your $targetCategory apps:";
            }
        }
      }
      if (targetCategory != null) {
        recommended = apps.where((app) => app.assignedCategoryName == targetCategory).toList();
      }
      if (recommended.isEmpty) {
        final sortedApps = List<InstalledApp>.from(apps)..sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedApps.take(5).toList();
        recMessage = "Your most used apps today:";
      }

      // 4. AI Image Generation (unchanged)
      String? aiImageUrl = state.aiImageUrl;
      if (totalUsage.inMinutes > 0) {
        emit(state.copyWith(isGeneratingImage: true));
        aiImageUrl = await GeminiService.generateVisualPrompt(categoryPercentages: percentages);
      }

      // 5. Success State
      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'Maria', 
        totalScreenTime: totalUsage,
        mostUsedCategory: topCategory,
        recommendedApps: recommended,
        allApps: apps,
        insightMessage: insight,
        recommendationMessage: recMessage,
        aiImageUrl: aiImageUrl,
        isGeneratingImage: false,
      ));
      
    } catch (e) {
      // --- CRITICAL UPDATE: CATCH PERMISSION ERRORS ---
      // Usually, app_usage throws a specific string when access is denied
      bool isPermissionError = e.toString().contains('Usage Access') || e.toString().contains('permission');
      
      emit(state.copyWith(
        status: isPermissionError ? DashboardStatus.failure : DashboardStatus.failure,
        // We can add a custom flag in DashboardState if we want to show a specific "Permission Required" UI
        isGeneratingImage: false,
      ));
    }
  }
}