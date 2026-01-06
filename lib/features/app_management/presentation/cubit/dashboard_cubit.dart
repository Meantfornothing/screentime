import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../../../core/services/gemini_service.dart';
import 'dashboard_state.dart';
import 'dart:math';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();

      Duration totalUsage = Duration.zero;
      final Map<String, Duration> categoryUsage = {};
      
      for (var app in apps) {
        totalUsage += app.usageDuration;
        final category = app.assignedCategoryName ?? 'Neutral'; // Standard till Neutral
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

      List<InstalledApp> recommended = [];
      String recMessage = "";
      String? targetCategory = categoryFilter;

      if (targetCategory == null && userCategories.isNotEmpty) {
        final otherCategories = userCategories
            .map((e) => e.name)
            .where((name) => name != topCategory && name != 'Neutral')
            .toList();
        
        if (otherCategories.isNotEmpty) {
          targetCategory = otherCategories[Random().nextInt(otherCategories.length)];
        }
      }

      if (targetCategory != null) {
        recommended = apps.where((app) => app.assignedCategoryName == targetCategory).toList();
        if (recommended.isNotEmpty) recMessage = "Switch to your $targetCategory apps:";
      }

      if (recommended.isEmpty) {
        final sortedApps = List<InstalledApp>.from(apps)..sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedApps.take(5).toList();
        recMessage = "Your most used apps today:";
      }

      String? aiImageUrl = state.aiImageUrl;
      if (totalUsage.inMinutes > 0) {
        emit(state.copyWith(isGeneratingImage: true));
        final Map<String, int> percentages = {};
        categoryUsage.forEach((cat, duration) {
          percentages[cat] = ((duration.inMinutes / totalUsage.inMinutes) * 100).round();
        });
        aiImageUrl = await GeminiService.generateVisualPrompt(categoryPercentages: percentages);
      }

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