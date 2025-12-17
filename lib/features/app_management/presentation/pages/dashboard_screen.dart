import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/routes.dart'; // Import routes for navigation

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
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFFD4AF98),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the new Preferences screen
              Navigator.pushNamed(context, AppRoutes.preferences);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService.showNotification(
            id: 999,
            title: 'Test Notification',
            body: 'This is a forced notification test.',
          );
        },
        backgroundColor: const Color(0xFFD4AF98),
        child: const Icon(Icons.notifications_active),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                Text(
                  'Hi ${state.userName}!',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Screen Time: ${state.totalScreenTime.inHours}h ${state.totalScreenTime.inMinutes % 60}m',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),

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
            width: 8,
            height: 8,
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