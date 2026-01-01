import 'dart:typed_data';
import 'package:flutter/material.dart';

class AppUsageTile extends StatelessWidget {
  final String appName;
  final Duration duration;
  final Uint8List? iconBytes;
  final String categoryName;

  const AppUsageTile({
    super.key,
    required this.appName,
    required this.duration,
    required this.categoryName,
    this.iconBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: iconBytes != null && iconBytes!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  iconBytes!,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: Colors.grey),
              ),
        title: Text(
          appName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          categoryName,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${duration.inMinutes}m",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text(
              "today",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}