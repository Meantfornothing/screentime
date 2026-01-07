import 'package:flutter/material.dart';
import 'setting_card.dart';
import '../../../../core/theme/app_visuals.dart';

/// A setting component with a slider input.
class SliderSetting extends StatefulWidget {
  final String title;
  final String description;
  final String minLabel;
  final String maxLabel;
  final double initialValue;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double value)? labelMapper;

  const SliderSetting({
    required this.title,
    required this.description,
    required this.minLabel,
    required this.maxLabel,
    required this.initialValue,
    required this.onChanged,
    this.divisions,
    this.labelMapper,
    super.key,
  });

  @override
  State<SliderSetting> createState() => _SliderSettingState();
}

class _SliderSettingState extends State<SliderSetting> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // The current value, mapped to a display label if a mapper is provided
    final String displayLabel = widget.labelMapper?.call(_currentValue) ?? '';
    
    return SettingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // Updated to brand primary text
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 14, 
              color: AppColors.textSecondary, // Updated to brand secondary text
            ),
          ),
          const SizedBox(height: 12),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _currentValue,
              min: 0.0,
              max: 1.0,
              divisions: widget.divisions,
              label: displayLabel.isNotEmpty ? displayLabel : null,
              activeColor: AppColors.primary, // Updated to brand beige
              inactiveColor: AppColors.primary.withOpacity(0.4), // Softer primary tint
              onChanged: (double newValue) {
                setState(() {
                  _currentValue = newValue;
                });
                widget.onChanged(newValue);
              },
            ),
          ),
          
          // Min/Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.minLabel, 
                  style: const TextStyle(
                    fontSize: 12, 
                    color: AppColors.textSecondary, // Consistency with theme
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.maxLabel, 
                  style: const TextStyle(
                    fontSize: 12, 
                    color: AppColors.textSecondary, // Consistency with theme
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}