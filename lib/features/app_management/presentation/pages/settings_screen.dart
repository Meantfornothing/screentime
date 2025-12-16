import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

// Import Cubit and State
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

// Import Widgets
import '../widgets/widgets.dart'; // Barrel import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Provide the SettingsCubit
    return BlocProvider(
      create: (context) => sl<SettingsCubit>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    // 2. Listen to state changes
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        
        if (state.status == SettingsStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98))),
          );
        }

        // 3. Extract settings for easier access
        final settings = state.settings;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const Text(
                        'Nudges',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 1. Length of Break Reminder
                      SliderSetting(
                        title: 'Length of Break Reminder',
                        description: 'How long before the app nudges you?',
                        minLabel: 'Short',
                        maxLabel: 'Long',
                        // Bind to state
                        initialValue: settings.breakReminderFrequency, 
                        onChanged: (value) {
                          // Call Cubit
                          context.read<SettingsCubit>().updateBreakFrequency(value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. Daily Screen Time Goal
                      SliderSetting(
                        title: 'Daily Screen Time Goal',
                        description: 'Set your ideal daily usage target.',
                        minLabel: '0h',
                        maxLabel: '10h',
                        // Convert minutes (0-600) to slider value (0.0-1.0)
                        initialValue: settings.dailyScreenTimeGoalMinutes / 600.0, 
                        divisions: 10,
                        labelMapper: (value) => '${(value * 10).round()}h',
                        onChanged: (value) {
                          // Convert slider (0.0-1.0) back to minutes (0-600)
                          final minutes = (value * 600).round();
                          context.read<SettingsCubit>().updateDailyGoal(minutes);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 3. Nudge Intensity
                      SliderSetting(
                        title: 'Nudge Intensity',
                        description: 'Soft = subtle suggestions, Firm = strong reminders.',
                        minLabel: 'Soft',
                        maxLabel: 'Firm',
                        initialValue: settings.nudgeIntensity, 
                        onChanged: (value) {
                          context.read<SettingsCubit>().updateNudgeIntensity(value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // 4. Bedtime Reminder
                      TimePickerSetting(
                        title: 'Bedtime Reminder',
                        description: 'Receive frequent reminders when it\'s getting late.',
                        initialTime: TimeOfDay(
                          hour: settings.bedtimeHour, 
                          minute: settings.bedtimeMinute
                        ),
                        // Note: You might need to update TimePickerSetting to accept an onChanged callback
                        // For now, we assume it's read-only or handled internally, 
                        // but ideally we pass a callback like:
                        // onTimeChanged: (time) => context.read<SettingsCubit>().updateBedtime(time.hour, time.minute),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                
                // Save Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Trigger save
                      context.read<SettingsCubit>().saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings saved!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF98),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}