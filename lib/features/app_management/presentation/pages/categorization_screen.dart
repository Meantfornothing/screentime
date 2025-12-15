import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

import '../cubit/categorization_cubit.dart';
import '../cubit/categorization_state.dart';

// --- Imports ---
import '../../domain/entities/app_category_entity.dart';
import '../widgets/app_assignment_tile.dart';

class CategorizationScreen extends StatelessWidget {
  const CategorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CategorizationCubit>()..loadData(),
      child: const _CategorizationView(),
    );
  }
}

class _CategorizationView extends StatelessWidget {
  const _CategorizationView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategorizationCubit, CategorizationState>(
      builder: (context, state) {
        
        if (state.status == CategorizationStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF98)),
            ),
          );
        }

        if (state.status == CategorizationStatus.failure) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${state.errorMessage}'),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'App Categorization',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Assign categories to get better recommendations.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                
                // Search & Filter (Sticky Header concept)
                _buildApplicationSearchAndFilter(),
                const SizedBox(height: 16),

                // Quick Category Filter (Horizontal Scroll)
                _buildAppListHeader(state.categories),
                const SizedBox(height: 12),

                // App List
                Expanded(
                  child: ListView.builder(
                    itemCount: state.apps.length,
                    itemBuilder: (context, index) {
                      final app = state.apps[index];
                      return AppAssignmentTile(
                        app: app,
                        availableCategories: state.categories,
                        onAssignCategory: (category) {
                          context.read<CategorizationCubit>().assignCategory(app.packageName, category);
                        },
                        // Callback to add new category directly from the tile
                        onAddNewCategory: (newCategoryName) {
                          context.read<CategorizationCubit>().addCategory(newCategoryName);
                          // Optionally auto-assign after creating:
                          context.read<CategorizationCubit>().assignCategory(app.packageName, newCategoryName);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Created category: $newCategoryName')),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationSearchAndFilter() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Search installed apps...',
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (query) {
            // Future feature: context.read<CategorizationCubit>().filterApps(query);
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Installed Apps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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

  Widget _buildAppListHeader(List<AppCategoryEntity> categories) {
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Chip(
            label: Text(categories[index].name),
            backgroundColor: Colors.grey.shade100,
            labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}