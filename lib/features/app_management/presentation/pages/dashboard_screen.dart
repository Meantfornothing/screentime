import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/insight_card.dart';
import '../widgets/recommendations_card.dart';
import 'preferences_screen.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core//services/background_service.dart';
import 'dart:async';
import '../../../../../core/theme/app_visuals.dart';

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
    // 1. Listen for notification taps while the app is open (foreground/background)
    _notificationSubscription = NotificationService.onTapStream.listen((payload) {
      _handlePayload(payload);
    });

    // 2. Check for the payload that launched the app (terminated state)
    NotificationService.getAppLaunchDetails().then((response) {
      if (response?.payload != null) {
        _handlePayload(response!.payload);
      }
    });
  }

  void _handlePayload(String? payload) {
    if (payload == null) return;

    // Standardize your payload parsing. 
    // Your BackgroundService uses 'target_category:Entertainment'
    String category = payload;
    if (payload.startsWith('target_category:')) {
      category = payload.replaceFirst('target_category:', '');
    }

    // Trigger the Cubit with the specific category filter
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  // 1. Header with Title and Settings Icon
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
                              style: TextStyle(
                                fontSize: 14, 
                                color: Colors.grey.shade600, 
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            const Text(
                              "Your Dashboard",
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.black
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 28),
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

                  // 2. Insight Card (Summary of usage)
                  InsightCard(content: state.insightMessage),

                  const SizedBox(height: 10),

                  // 3. Recommendations Card (Apps based on current context/nudge)
                  RecommendationsCard(
                    content: state.recommendationMessage,
                    recommendedApps: state.recommendedApps,
                    getCategoryColor: AppColors.getCategoryColor,
                  ),

                  const SizedBox(height: 20),

                  // 4. Test Notification Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // FIX: Calling NotificationService statically. 
                        // Note: Instances (from sl) cannot access static members.
                        // We must provide 'id', 'title', and 'body' as required by your service.
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
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}