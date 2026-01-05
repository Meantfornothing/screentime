import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_visuals.dart'; // Import the theme
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/category_summary_tile.dart';
import '../widgets/app_usage_tile.dart';

class UsageTimeScreen extends StatelessWidget {
  const UsageTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use themed background
      appBar: AppBar(
        title: const Text(
          'Detailed Usage',
          style: TextStyle(
            color: AppColors.textPrimary, // Use themed primary text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background, // Match scaffold background
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary), // Themed icons
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary), // Themed loader
            );
          }

          final displayApps = state.allApps;

          final Map<String, Duration> categoryTotals = {};
          for (var app in displayApps) {
            final cat = app.assignedCategoryName ?? 'Uncategorized';
            categoryTotals[cat] = (categoryTotals[cat] ?? Duration.zero) + app.usageDuration;
          }

          if (displayApps.isEmpty) {
            return const Center(
              child: Text(
                "No usage data recorded yet.",
                style: TextStyle(color: AppColors.textSecondary), // Themed secondary text
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Category Summary",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Themed header
                ),
              ),
              const SizedBox(height: 15),
              ...categoryTotals.entries.map((entry) => CategorySummaryTile(
                    categoryName: entry.key,
                    duration: entry.value,
                  )),
              const Divider(
                height: 40, 
                color: AppColors.surface, // Use surface color for subtle divider
              ),
              const Text(
                "App Breakdown",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Themed header
                ),
              ),
              const SizedBox(height: 15),
              ...displayApps.map((app) => AppUsageTile(
                    appName: app.name,
                    duration: app.usageDuration,
                    iconBytes: app.iconBytes,
                    categoryName: app.assignedCategoryName ?? 'Uncategorized',
                  )),
            ],
          );
        },
      ),
    );
  }
}