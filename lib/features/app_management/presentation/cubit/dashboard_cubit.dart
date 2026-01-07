// lib/features/app_management/presentation/cubit/dashboard_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Fetch data from repositories
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();
      final settings = await settingsRepository.getSettings();

      Duration totalUsage = Duration.zero;
      final Map<String, Duration> categoryUsage = {};
      
      for (var app in apps) {
        totalUsage += app.usageDuration;
        final category = app.assignedCategoryName ?? 'Neutral';
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

      // 2. Percentage Calculation & AI Insight Message
      final Map<String, int> percentages = {};
      String insight = totalUsage.inMinutes == 0 
          ? "No usage data yet. Categorize apps to see detailed insights!" 
          : "You've used your phone for ${totalUsage.inMinutes}m today.";

      if (totalUsage.inMinutes > 0) {
        // Calculate Percentages once for both AI features
        categoryUsage.forEach((cat, duration) {
          percentages[cat] = ((duration.inMinutes / totalUsage.inMinutes) * 100).round();
        });

        // Generate AI-powered reflective insight
        final aiInsight = await GeminiService.generateInsightMessage(
          userGoal: settings.userGoal,
          categoryPercentages: percentages,
        );
        if (aiInsight != null) insight = aiInsight;
      }

      // 3. Goal-Based Recommendation Logic
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

      // 4. AI Image Generation
      String? aiImageUrl = state.aiImageUrl;
      if (totalUsage.inMinutes > 0) {
        emit(state.copyWith(isGeneratingImage: true));
        // Use the percentages calculated above
        aiImageUrl = await GeminiService.generateVisualPrompt(categoryPercentages: percentages);
      }

      // 5. Final State Update
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
      emit(state.copyWith(status: DashboardStatus.failure, isGeneratingImage: false));
    }
  }
}