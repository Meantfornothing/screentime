import 'package:flutter/material.dart';
// Replicates the list item for an existing category (Top of the screen).
class CategoryListTile extends StatelessWidget {
  final String name;
  final VoidCallback onDelete;

  const CategoryListTile({required this.name, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}