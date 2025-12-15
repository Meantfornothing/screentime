import 'package:flutter/material.dart';

/// The Insights Card with a simple text message
class InsightsCard extends StatelessWidget {
  final String content;
  const InsightsCard({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
