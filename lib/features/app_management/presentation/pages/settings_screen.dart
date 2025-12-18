import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

// Import Cubit and State
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

// Import Widgets
import '../widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        
        if (state.status == SettingsStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98))),
          );
        }

        final settings = state.settings;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      // 2. Added a manual back button and header area
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Nudge Settings',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      SliderSetting(
                        title: 'Nudge Frequency', 
                        description: 'How often should we remind you?',
                        minLabel: 'Rarely',
                        maxLabel: 'Often',
                        initialValue: settings.breakReminderFrequency, 
                        onChanged: (value) {
                          context.read<SettingsCubit>().updateBreakFrequency(value);
                        },
                      ),
                      const SizedBox(height: 20),

                      SliderSetting(
                        title: 'Daily Screen Time Goal',
                        description: 'Set your ideal daily usage target.',
                        minLabel: '0h',
                        maxLabel: '10h',
                        initialValue: settings.dailyScreenTimeGoalMinutes / 600.0, 
                        divisions: 10,
                        labelMapper: (value) => '${(value * 10).round()}h',
                        onChanged: (value) {
                          final minutes = (value * 600).round();
                          context.read<SettingsCubit>().updateDailyGoal(minutes);
                        },
                      ),
                      const SizedBox(height: 20),

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

                      TimePickerSetting(
                        title: 'Bedtime Reminder',
                        description: 'Receive frequent reminders when it\'s getting late.',
                        initialTime: TimeOfDay(
                          hour: settings.bedtimeHour, 
                          minute: settings.bedtimeMinute
                        ),
                        onTimeChanged: (newTime) {
                          context.read<SettingsCubit>().updateBedtime(newTime.hour, newTime.minute);
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // Fixed Save Button at the bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SettingsCubit>().saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF98),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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