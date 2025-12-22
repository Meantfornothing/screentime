import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/routes.dart';
import '../../../../main.dart'; // REQUIRED to access pendingCategoryFilter

import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../domain/entities/entities.dart';
import '../widgets/widgets.dart';

Color getCategoryColor(String name) {
  switch (name) {
    case 'Relaxation': return Colors.blue.shade600;
    case 'Entertainment': return Colors.red.shade600;
    case 'Productivity': return Colors.green.shade600;
    default: return Colors.grey;
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardCubit>()..loadDashboardData(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    // UPDATED: Check for the filter when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingCategoryFilter != null) {
        context.read<DashboardCubit>().loadDashboardData(categoryFilter: pendingCategoryFilter);
        pendingCategoryFilter = null; // Clear it so it doesn't persist
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.preferences),
          label: const Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.settings),
          backgroundColor: const Color(0xFFD4AF98),
          foregroundColor: Colors.white,
          elevation: 6,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading) {
               return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98)));
            }
            if (state.status == DashboardStatus.failure) {
              return Center(child: Text('Error: ${state.insightMessage}'));
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 120.0), 
              children: [
                Text('Hi ${state.userName}!', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Total Screen Time: ${state.totalScreenTime.inHours}h ${state.totalScreenTime.inMinutes % 60}m',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                // --- TEST NOTIFICATION SECTION ---
                const SizedBox(height: 20),
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text("Developer Test Tools", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _triggerTestSwapNotification(),
                          icon: const Icon(Icons. notification_important),
                          label: const Text("Simulate 'Productivity' Swap Nudge"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                // ---------------------------------
                const SizedBox(height: 30),
                const AspectRatio(aspectRatio: 16 / 9, child: PlaceholderChart()),
                const SizedBox(height: 16),
                _buildCategoryLegend(),
                const SizedBox(height: 30),
                const Text('Insights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                InsightsCard(content: state.insightMessage),
                const SizedBox(height: 30),
                Text(state.recommendationMessage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                RecommendationsCard(
                  content: state.recommendationMessage,
                  recommendedApps: state.recommendedApps,
                  getCategoryColor: getCategoryColor, 
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: () => NotificationService.showNotification(
                    id: 999, title: 'System Check', body: 'Notifications are active!'
                  ),
                  icon: const Icon(Icons.notifications_active, size: 14),
                  label: const Text('Test Notification System', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade400),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper function to trigger the notification manually
  void _triggerTestSwapNotification() {
    NotificationService.showNotification(
      id: 888,
      title: "Great work!",
      body: "You've been productive for a while. Why not switch to an Entertainment app?",
      payload: 'target_category:Entertainment', // This triggers the swap logic on tap
    );
  }

  Widget _buildCategoryLegend() {
    final categories = ['Relaxation', 'Entertainment', 'Productivity'];
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: categories.map((category) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: getCategoryColor(category), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(category, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      )).toList(),
    );
  }
}