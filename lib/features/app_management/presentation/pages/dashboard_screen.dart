// lib/features/app_management/presentation/pages/dashboard_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/widgets.dart'; // Ensure AiArtworkCard, DashboardLegend, InsightCard, etc. are here
import 'preferences_screen.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_visuals.dart';
import '../../../../core/utils/nudge_logic.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  StreamSubscription? _notificationSubscription;
  
  // Tracks if the ACTUAL Android system has granted permission
  bool _isSystemPermissionGranted = true;

  @override
  void initState() {
    super.initState();
    // Register the observer to detect when Maria returns from Android Settings
    WidgetsBinding.instance.addObserver(this);
    
    _setupNotificationHandling();
    _checkRealSystemPermission(); 
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Detects when the app is brought back to the foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkRealSystemPermission();
    }
  }

  // The "Canary Fetch": Tries to get real data to see if the system is unlocked
  Future<void> _checkRealSystemPermission() async {
    try {
      DateTime now = DateTime.now();
      await AppUsage().getAppUsage(now.subtract(const Duration(seconds: 1)), now);
      if (mounted) setState(() => _isSystemPermissionGranted = true);
    } catch (e) {
      // If an error occurs, permission is missing
      if (mounted) setState(() => _isSystemPermissionGranted = false);
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            // Show global loader only on initial boot
            if (state.status == DashboardStatus.loading && !state.isGeneratingImage) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Stack(
              children: [
                // --- LAYER 0: THE DASHBOARD ---
                RefreshIndicator(
                  onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      _buildHeader(state),
                      const SizedBox(height: 25),

                      AiArtworkCard(
                        imageUrl: state.aiImageUrl,
                        isGenerating: state.isGeneratingImage,
                      ),
                      
                      if (state.aiImageUrl != null || state.isGeneratingImage)
                        const DashboardLegend(),

                      const SizedBox(height: 10),
                      InsightCard(content: state.insightMessage),
                      const SizedBox(height: 10),
                      RecommendationsCard(
                        content: state.recommendationMessage,
                        recommendedApps: state.recommendedApps,
                        getCategoryColor: AppColors.getCategoryColor,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildTestNudgeButton(state),
                    ],
                  ),
                ),

                // --- LAYER 1: PERMISSION OVERLAY ---
                if (!_isSystemPermissionGranted)
                  _buildPermissionOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${state.userName}",
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const Text(
                "Your Dashboard",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen())),
            icon: const Icon(Icons.settings_outlined, size: 20, color: AppColors.textPrimary),
            label: const Text("My Preferences", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.buttonRadius)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person_rounded, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            "System Access Required",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "To accurately visualize Maria's phone usage, ReAlign needs 'Usage Access' permission in your Android settings.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<DashboardCubit>().ensureSystemPermissions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text("Open Android Settings"),
          ),
        ],
      ),
    );
  }

    Widget _buildTestNudgeButton(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () async {
          // 1. Get current settings (intensity and goal)
          final settings = context.read<SettingsCubit>().state.settings;
          final intensity = settings.nudgeIntensity;

          // 2. Determine target category
          final String focusCategory = state.recommendedApps.isNotEmpty 
              ? (state.recommendedApps.first.assignedCategoryName ?? "Productivity")
              : "Productivity";

          // 3. Trigger notification using your new utility
          await NotificationService.showNotification(
            id: 1,
            title: NudgeLogic.getTitle(intensity),
            body: NudgeLogic.getBody(intensity, focusCategory),
            payload: focusCategory,
            importance: intensity > 0.7 ? Importance.max : Importance.defaultImportance,
          );
        },
        icon: const Icon(Icons.bolt, color: AppColors.primary),
        label: const Text("Test Goal Nudge"),
        // ... style code ...
      ),
    );
  }
}