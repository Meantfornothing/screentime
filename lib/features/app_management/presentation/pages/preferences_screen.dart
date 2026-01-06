// lib/features/app_management/presentation/pages/preferences_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/routes.dart';
import '../../../../core/theme/app_visuals.dart';
import '../../domain/entities/user_settings_entity.dart'; // Import added

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/widgets.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsCubit>()..loadSettings(),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    // Removed local goal list - now using UserSettingsEntity.allGoals

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final currentGoal = state.settings.userGoal;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // --- HEADER ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Preferences',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- GOAL SELECTION ---
                const Text(
                  'What is your main goal?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                SettingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Goal', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        // Handle potential legacy values from Hive
                        value: UserSettingsEntity.allGoals.contains(currentGoal) 
                            ? currentGoal 
                            : UserSettingsEntity.allGoals.first,
                        isExpanded: true, // Crucial for long text
                        dropdownColor: AppColors.surface,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
                            borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: UserSettingsEntity.allGoals.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value, 
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              overflow: TextOverflow.visible, // Allow multiline in dropdown
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            context.read<SettingsCubit>().updateUserGoal(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                
                // --- QUICK ACCESS SECTION ---
                const Text(
                  'Quick Access', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                ),
                const SizedBox(height: 16),
                _NavigationTile(
                  icon: Icons.category,
                  title: 'Categorize Apps',
                  subtitle: 'Manage your app categories',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.categorization),
                ),
                const SizedBox(height: 12),
                _NavigationTile(
                  icon: Icons.tune,
                  title: 'Nudge Settings',
                  subtitle: 'Adjust frequency and intensity',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppShapes.buttonRadius),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            AppIconBox(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}