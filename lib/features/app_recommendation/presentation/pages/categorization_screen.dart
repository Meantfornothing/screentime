import 'package:flutter/material.dart';

// --- Import Domain Entities ---
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app.dart';

// --- Import Feature Widgets ---
import '../widgets/app_assignment_tile.dart';
import '../widgets/category_action_button.dart';
import '../widgets/category_list_tile.dart';


// --- Placeholder Data for Demonstration (Uses Domain Entities) ---
final List<AppCategoryEntity> mockCategories = [
  AppCategoryEntity(id: '1', name: 'Entertainment'),
  AppCategoryEntity(id: '2', name: 'Productivity'),
  AppCategoryEntity(id: '3', name: 'Neutral'),
];

final List<InstalledApp> mockApps = [
  InstalledApp(packageName: 'com.social.app1', name: 'Application A', assignedCategoryName: 'Relaxation'),
  InstalledApp(packageName: 'com.game.app2', name: 'Application B', assignedCategoryName: 'Entertainment'),
  InstalledApp(packageName: 'com.work.app3', name: 'Application C', assignedCategoryName: 'Productivity'),
  InstalledApp(packageName: 'com.utility.app4', name: 'Application D'), // Uncategorized
];
// ------------------------------------------

class CategorizationScreen extends StatelessWidget {
  const CategorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget now returns only the body content, relying on MainWrapper for the Scaffold, AppBar, and BottomNavigationBar.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverToBoxAdapter(child: Text(
              'Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // 1. Category Management Section
            SliverToBoxAdapter(
              child: _buildCategoryManagementSection(context),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 2. Applications Section
            const SliverToBoxAdapter(child: Text(
              'Applications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _buildApplicationSearchAndFilter(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // App Assignment List Header
            SliverToBoxAdapter(
              child: _buildAppListHeader(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 3. App Assignment List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = mockApps[index];
                  return AppAssignmentTile(
                    app: app,
                    onAssignCategory: (category) {
                      // BLoC: rulesBloc.add(AssignCategory(app.packageName, category));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Assigned ${app.name} to $category')),
                      );
                    },
                    availableCategories: mockCategories,
                  );
                },
                childCount: mockApps.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for Bottom Nav Bar
          ],
        ),
      ),
    );
  }

  // --- Widget Builders for Sections ---

  Widget _buildCategoryManagementSection(BuildContext context) {
    final brownColor = Colors.brown.shade300;
    
    return Column(
      children: [
        // Add Button
        CategoryActionButton( 
          label: 'Add',
          icon: Icons.add_circle_outline,
          color: brownColor,
          onPressed: () {
            // BLoC: rulesBloc.add(AddNewCategory());
            _showCategoryAddDialog(context);
          },
        ),
        const SizedBox(height: 10),

        // List of existing categories
        ...mockCategories.map((category) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CategoryListTile( 
            name: category.name,
            onDelete: () {
              // BLoC: rulesBloc.add(DeleteCategory(category.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted category: ${category.name}')),
              );
            },
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildApplicationSearchAndFilter() {
    return Column(
      children: [
        // Search Bar
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Search app...',
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            suffixIcon: const Icon(Icons.mic, color: Colors.black54),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (query) {
            // BLoC: rulesBloc.add(SearchApps(query));
          },
        ),
        const SizedBox(height: 10),

        // Sort and Filter Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Apps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 16, color: Colors.black54),
                  label: const Text('Sort', style: TextStyle(color: Colors.black54)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 16, color: Colors.black54),
                  label: const Text('Filter', style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppListHeader() {
    // This replicates the header with category chips and the arrow.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: mockCategories.map((c) => Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(c.name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
            )).toList(),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        ],
      ),
    );
  }

  // --- Helper: Dialog for adding a new category ---
  void _showCategoryAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: const TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'e.g., Learning, Fitness, Wasted Time'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                // Logic to save the new category via BLoC/Cubit
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}