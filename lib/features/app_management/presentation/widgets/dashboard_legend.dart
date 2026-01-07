import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart';
import 'legend_item.dart'; // Assuming LegendItem is in its own file

class DashboardLegend extends StatelessWidget {
  const DashboardLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          LegendItem(label: "Social", color: AppColors.social),
          LegendItem(label: "Entertainment", color: AppColors.entertainment),
          LegendItem(label: "Productivity", color: AppColors.productivity),
          LegendItem(label: "Relaxation", color: AppColors.relaxation),
        ],
      ),
    );
  }
}