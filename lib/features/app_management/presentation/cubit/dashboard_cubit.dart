import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../../../core/services/gemini_service.dart'; // Importera din nya tjänst
import 'dashboard_state.dart';
import 'dart:math';

class DashboardCubit extends Cubit<DashboardState> {
  final CategorizationRepository repository;

  DashboardCubit(this.repository) : super(const DashboardState());

  Future<void> loadDashboardData({String? categoryFilter}) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    try {
      // 1. Hämta appar och kategorier
      final apps = await repository.getInstalledApps();
      final userCategories = await repository.getCategories();

      // 2. Beräkna total skärmtid
      Duration totalUsage = Duration.zero;
      for (var app in apps) {
        totalUsage += app.usageDuration;
      }

      // 3. Aggregera användning per kategori
      final Map<String, Duration> categoryUsage = {};
      for (var app in apps) {
        final category = app.assignedCategoryName ?? 'Uncategorized';
        categoryUsage[category] = (categoryUsage[category] ?? Duration.zero) + app.usageDuration;
      }

      // 4. Identifiera toppkategorin
      String topCategory = 'None';
      Duration topDuration = Duration.zero;
      categoryUsage.forEach((key, value) {
        if (value > topDuration) {
          topDuration = value;
          topCategory = key;
        }
      });

      // 5. Skapa insiktsmeddelande
      String insight = "You've used your phone for ${totalUsage.inMinutes}m today.";
      if (topCategory != 'None' && topDuration.inMinutes > 0) {
        insight += " Most time spent in $topCategory (${topDuration.inMinutes}m).";
      } else if (totalUsage.inMinutes == 0) {
        insight = "No usage data yet. Categorize apps to see detailed insights!";
      }

      // 6. Rekommendationslogik (Swap)
      List<InstalledApp> recommended = [];
      String recMessage = "";
      String? targetCategory = categoryFilter;

      if (targetCategory == null && userCategories.isNotEmpty) {
        final otherCategories = userCategories
            .map((e) => e.name)
            .where((name) => name != topCategory)
            .toList();
        
        if (otherCategories.isNotEmpty) {
          targetCategory = otherCategories[Random().nextInt(otherCategories.length)];
        }
      }

      if (targetCategory != null) {
        recommended = apps.where((app) => app.assignedCategoryName == targetCategory).toList();
        if (recommended.isNotEmpty) {
          recMessage = "Switch to your $targetCategory apps:";
        }
      }

      if (recommended.isEmpty) {
        final sortedAppsByUsage = List<InstalledApp>.from(apps);
        sortedAppsByUsage.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));
        recommended = sortedAppsByUsage.take(5).toList();
        recMessage = "Your most used apps today:";
      }

      // --- NYTT: BILDGENERERING BASERAT PÅ PROCENT ---
      String? aiImageUrl = state.aiImageUrl;
      final totalMinutes = totalUsage.inMinutes;

      if (totalMinutes > 0) {
        emit(state.copyWith(isGeneratingImage: true));

        // Beräkna procentuell fördelning för Gemini
        final Map<String, int> percentages = {};
        categoryUsage.forEach((cat, duration) {
          percentages[cat] = ((duration.inMinutes / totalMinutes) * 100).round();
        });

        // Generera bild-URL via Gemini och Pollinations
        aiImageUrl = await GeminiService.generateVisualPrompt(
          categoryPercentages: percentages,
        );
      }

      // 7. Emit success state med den genererade bilden
      emit(state.copyWith(
        status: DashboardStatus.success,
        userName: 'User', 
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
      emit(state.copyWith(
        status: DashboardStatus.failure,
        insightMessage: "Error loading data: ${e.toString()}",
        isGeneratingImage: false,
      ));
    }
  }
}