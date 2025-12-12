import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

import '../cubit/categorization_cubit.dart';
import '../cubit/categorization_state.dart';

import '../../domain/entities/entities.dart';

import '../widgets/widgets.dart';

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
          return const Center(child: CircularProgressIndicator());
        }
        
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
                
                SliverToBoxAdapter(
                  child: _buildCategoryManagementSection(context, state.categories),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                const SliverToBoxAdapter(child: Text(
                  'Applications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                )),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                SliverToBoxAdapter(
                  child: _buildApplicationSearchAndFilter(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverToBoxAdapter(
                  child: _buildAppListHeader(state.categories),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final app = state.apps[index];
                      return AppAssignmentTile(
                        app: app,
                        onAssignCategory: (category) {
                          context.read<CategorizationCubit>().assignCategory(app.packageName, category);
                        },
                        availableCategories: state.categories,
                      );
                    },
                    childCount: state.apps.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryManagementSection(BuildContext context, List<AppCategoryEntity> categories) {
    final brownColor = Colors.brown.shade300;
    return Column(
      children: [
        CategoryActionButton( 
          label: 'Add',
          icon: Icons.add_circle_outline,
          color: brownColor,
          onPressed: () => _showCategoryAddDialog(context),
        ),
        const SizedBox(height: 10),
        ...categories.map((category) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CategoryListTile( 
            name: category.name,
            onDelete: () => context.read<CategorizationCubit>().deleteCategory(category.id),
          ),
        )),
      ],
    );
  }

  Widget _buildApplicationSearchAndFilter() {
    return Column(
      children: [
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
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('All Apps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Row(children: [Icon(Icons.filter_list), Text(" Filter")]),
          ],
        ),
      ],
    );
  }

  Widget _buildAppListHeader(List<AppCategoryEntity> categories) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(c.name, style: const TextStyle(fontSize: 12)),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryAddDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Learning'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  context.read<CategorizationCubit>().addCategory(textController.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}