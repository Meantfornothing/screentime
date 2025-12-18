import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/routes.dart';

// Import Cubit and State
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

// Import Entities and Widgets
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

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. & 3. Removed AppBar and updated the button to be a centered, highly visible Extended FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.preferences);
          },
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
              return Center(child: Text('Failed to load dashboard: ${state.insightMessage}'));
            }

            return ListView(
              // Increased bottom padding to prevent FAB from overlapping content
              padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 120.0), 
              children: [
                // Header Replacement
                Text(
                  'Hi ${state.userName}!',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Screen Time: ${state.totalScreenTime.inHours}h ${state.totalScreenTime.inMinutes % 60}m',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PlaceholderChart(), 
                ),
                const SizedBox(height: 16),

                _buildCategoryLegend(),
                const SizedBox(height: 30),

                const Text(
                  'Insights',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                InsightsCard(content: state.insightMessage),
                const SizedBox(height: 30),

                const Text(
                  'Suggested Apps', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                RecommendationsCard(
                  content: state.recommendationMessage,
                  recommendedApps: state.recommendedApps,
                  getCategoryColor: getCategoryColor, 
                ),
                const SizedBox(height: 30),

                // Manual test link at bottom
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

  Widget _buildCategoryLegend() {
    final categories = ['Relaxation', 'Entertainment', 'Productivity'];
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: categories.map((category) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      )).toList(),
    );
  }
}