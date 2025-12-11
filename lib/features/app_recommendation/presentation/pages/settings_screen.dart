import 'package:flutter/material.dart';
// Ensure these imports match your local widget files
import '../widgets/setting_card.dart'; // Assuming chart.dart is now placeholder_chart.dart
import '../widgets/slider_setting.dart'; // Assuming insight_card.dart is now insights_card.dart
import '../widgets/timepicker_setting.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We rely on MainWrapper for the main Scaffold, but we use an inner Scaffold
      // here to simplify saving state, although we currently only return the body.
      // The SafeArea is crucial for full-screen content.
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
                    initialValue: 0.4, // Mock value
                    onChanged: (value) {
                      // BLoC: settingsBloc.add(UpdateBreakLength(value));
                    },
                  ),
                  const SizedBox(height: 20),

                  // 2. Daily Screen Time Goal
                  SliderSetting(
                    title: 'Daily Screen Time Goal',
                    description: 'Set your ideal daily usage target.',
                    minLabel: '0h',
                    maxLabel: '10h',
                    initialValue: 0.6, // Mock value (6 hours)
                    divisions: 10,
                    labelMapper: (value) => '${(value * 10).round()}h', // Maps 0-1 to 0-10 hours
                    onChanged: (value) {
                      // BLoC: settingsBloc.add(UpdateDailyGoal(value * 10));
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Nudge Intensity
                  SliderSetting(
                    title: 'Nudge Intensity',
                    description: 'Soft = subtle suggestions, Firm = strong reminders.',
                    minLabel: 'Soft',
                    maxLabel: 'Firm',
                    initialValue: 0.7, // Mock value
                    onChanged: (value) {
                      // BLoC: settingsBloc.add(UpdateNudgeIntensity(value));
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Bedtime Reminder
                  const TimePickerSetting(
                    title: 'Bedtime Reminder',
                    description: 'Receive frequent reminders when it\'s getting late.',
                    initialTime: TimeOfDay(hour: 23, minute: 0),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // Save Button (Fixed at the bottom)
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
                  // BLoC: settingsBloc.add(SaveSettings());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF98), // Brown/Beige color from mock
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
  }
}







/// A setting component with a time picker input.
class TimePickerSetting extends StatefulWidget {
  final String title;
  final String description;
  final TimeOfDay initialTime;

  const TimePickerSetting({
    required this.title,
    required this.description,
    required this.initialTime,
    super.key,
  });

  @override
  State<TimePickerSetting> createState() => _TimePickerSettingState();
}

class _TimePickerSettingState extends State<TimePickerSetting> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  // Helper to format time (e.g., 23:00 -> 11:00 PM)
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD4AF98), // Primary color for dialog
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _selectedTime = newTime;
      });
      // BLoC: settingsBloc.add(UpdateBedtime(newTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString = _selectedTime.format(context).split(' ');
    final timePart = timeString[0];
    final amPmPart = timeString.length > 1 ? timeString[1] : null;

    return SettingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Time',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timePart,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4AF98)),
                      ),
                      if (amPmPart != null) ...[
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAmPmButton('AM', amPmPart == 'AM', _pickTime),
                            _buildAmPmButton('PM', amPmPart == 'PM', _pickTime),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmPmButton(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap, // Tapping changes the time/opens picker
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF98) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFD4AF98) : Colors.grey.shade400,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}