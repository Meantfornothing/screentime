import 'package:flutter/material.dart';
import 'setting_card.dart'; // We will create this next

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

  // --- THIS IS THE FUNCTION YOU ASKED ABOUT ---
  Future<void> _pickTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        // This customizes the clock dial colors to match your design
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD4AF98), // Your Brown/Beige color
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
      // Logic to save the time would go here (e.g. calling a BLoC)
    }
  }
  // ---------------------------------------------

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
                onTap: _pickTime, // Calls the function above
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
                            _buildAmPmButton('AM', amPmPart == 'AM'),
                            _buildAmPmButton('PM', amPmPart == 'PM'),
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
  
  Widget _buildAmPmButton(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      // Tapping these also triggers the picker for better UX
      child: InkWell(
        onTap: _pickTime, 
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