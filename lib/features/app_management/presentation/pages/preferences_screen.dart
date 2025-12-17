import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/routes.dart'; // Import routes for navigation

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/widgets.dart'; // Using SettingCard

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-use the SettingsCubit since we are modifying UserSettingsEntity
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
    final List<String> goals = [
      'Reduce Screen Time',
      'Improve Sleep',
      'Increase Focus',
      'Digital Detox',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Preferences'),
        backgroundColor: const Color(0xFFD4AF98),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98)));
          }

          final currentGoal = state.settings.userGoal;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                'What is your main goal?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Dropdown inside a Setting Card
              SettingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Goal', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: goals.contains(currentGoal) ? currentGoal : goals.first,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: goals.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          context.read<SettingsCubit>().updateUserGoal(newValue);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Goal set to: $newValue')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              const Text('Quick Access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Navigation Buttons
              _NavigationTile(
                icon: Icons.category,
                title: 'Categorize Apps',
                subtitle: 'Manage your app categories',
                onTap: () {
                   // Navigate to MainWrapper but switch tab? 
                   // Or push screen directly. Let's push directly for now.
                   Navigator.pushNamed(context, AppRoutes.categorization);
                },
              ),
              const SizedBox(height: 12),
              _NavigationTile(
                icon: Icons.tune,
                title: 'Nudge Settings',
                subtitle: 'Adjust frequency and intensity',
                onTap: () {
                   Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
            ],
          );
        },
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF98).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFD4AF98)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}