import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

// Import Cubit and State
import '../cubit/categorization_cubit.dart';
import '../cubit/categorization_state.dart';

// Import Widgets
import '../widgets/widgets.dart'; // Barrel import for AppAssignmentTile, etc.

class CategorizationScreen extends StatelessWidget {
  const CategorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Providing the Cubit here ensures that when you navigate via 
    // Navigator.pushNamed from Preferences, the Cubit is available in the context.
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorization'),
        backgroundColor: const Color(0xFFD4AF98),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CategorizationCubit, CategorizationState>(
        builder: (context, state) {
          if (state.status == CategorizationStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98)));
          }

          if (state.status == CategorizationStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.apps.length,
            itemBuilder: (context, index) {
              final app = state.apps[index];
              return AppAssignmentTile(
                app: app,
                // FIX: Updated parameter names to match the AppAssignmentTile constructor
                availableCategories: state.categories,
                onAssignCategory: (categoryName) {
                  context.read<CategorizationCubit>().assignCategory(
                        app.packageName,
                        categoryName,
                      );
                },
                onAddNewCategory: (newCategoryName) {
                  context.read<CategorizationCubit>().addCategory(newCategoryName);
                  // Optionally assign it immediately
                  context.read<CategorizationCubit>().assignCategory(
                        app.packageName,
                        newCategoryName,
                      );
                },
              );
            },
          );
        },
      ),
      // Button to add new categories manually
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color(0xFFD4AF98),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // We use the 'context' from the outer view which contains the Cubit
                context.read<CategorizationCubit>().addCategory(controller.text);
                Navigator.pop(innerContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}