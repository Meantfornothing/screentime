// lib/features/app_management/presentation/pages/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/insight_card.dart';
import '../widgets/recommendations_card.dart';
import 'preferences_screen.dart';
import '../../../../core/services/notification_service.dart';
import 'dart:async';
import '../../../../core/theme/app_visuals.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationHandling();
    context.read<DashboardCubit>().loadDashboardData();
  }

  void _setupNotificationHandling() {
    _notificationSubscription = NotificationService.onTapStream.listen((payload) {
      _handlePayload(payload);
    });

    NotificationService.getAppLaunchDetails().then((response) {
      if (response?.payload != null) {
        _handlePayload(response!.payload);
      }
    });
  }

  void _handlePayload(String? payload) {
    if (payload == null) return;
    String category = payload;
    if (payload.startsWith('target_category:')) {
      category = payload.replaceFirst('target_category:', '');
    }
    context.read<DashboardCubit>().loadDashboardData(categoryFilter: category);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading && !state.isGeneratingImage) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ${state.userName}",
                              style: const TextStyle(
                                fontSize: 14, 
                                color: AppColors.textSecondary, 
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            const Text(
                              "Your Dashboard",
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold, 
                                color: AppColors.textPrimary
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 28, color: AppColors.textPrimary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PreferencesScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- AI VISUALIZATION (ARTWORK) ---
                  _buildAiArtwork(state),

                  const SizedBox(height: 10),
                  InsightCard(content: state.insightMessage),
                  const SizedBox(height: 10),
                  RecommendationsCard(
                    content: state.recommendationMessage,
                    recommendedApps: state.recommendedApps,
                    getCategoryColor: AppColors.getCategoryColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // --- TEST NOTIFICATION BUTTON ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await NotificationService.showNotification(
                          id: 1,
                          title: "Productivity Boost?",
                          body: "It's time to focus. Switch to your Productivity apps.",
                          payload: "Productivity", 
                        );
                      },
                      icon: const Icon(Icons.notification_add_outlined),
                      label: const Text("Test Clickable Swap Nudge"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppShapes.buttonRadius)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiArtwork(DashboardState state) {
    return Container(
      height: 280,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // The Generated Image
          if (state.aiImageUrl != null)
            Positioned.fill(
              child: Image.network(
                state.aiImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
                ),
              ),
            ),
          
          // Loading Overlay for AI Generation
          if (state.isGeneratingImage)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "AI is painting your day...",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          
          // Placeholder when no data/image exists
          if (state.aiImageUrl == null && !state.isGeneratingImage)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Categorize apps to see your daily art",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}