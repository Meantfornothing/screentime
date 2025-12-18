import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';

// Import Cubit and State
import '../cubit/categorization_cubit.dart';
import '../cubit/categorization_state.dart';

// Import Widgets
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

class _CategorizationView extends StatefulWidget {
  const _CategorizationView();

  @override
  State<_CategorizationView> createState() => _CategorizationViewState();
}

class _CategorizationViewState extends State<_CategorizationView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedCategoryFilter; // null = All, "Uncategorized" = Uncategorized, else specific category

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CategorizationCubit, CategorizationState>(
          builder: (context, state) {
            if (state.status == CategorizationStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF98)));
            }

            if (state.status == CategorizationStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            // --- SEARCH & FILTER LOGIC ---
            final filteredApps = state.apps.where((app) {
              // 1. Search Query filter
              final matchesSearch = app.name.toLowerCase().contains(_searchQuery.toLowerCase());
              
              // 2. Category Filter
              bool matchesCategory = true;
              if (_selectedCategoryFilter != null) {
                if (_selectedCategoryFilter == "Uncategorized") {
                  matchesCategory = app.assignedCategoryName == null;
                } else {
                  matchesCategory = app.assignedCategoryName == _selectedCategoryFilter;
                }
              }

              return matchesSearch && matchesCategory;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Categorization',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      // NEW: Refresh button to clear cache and re-fetch from OS
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFFD4AF98)),
                        tooltip: 'Refresh App List',
                        onPressed: () {
                          context.read<CategorizationCubit>().loadData(forceRefresh: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refreshing app list...'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF98)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    ),
                  ),
                ),

                // Filter Row
                _buildFilterRow(state.categories),

                const SizedBox(height: 8),

                // App List
                Expanded(
                  child: filteredApps.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return AppAssignmentTile(
                            app: app,
                            availableCategories: state.categories,
                            onAssignCategory: (categoryName) {
                              context.read<CategorizationCubit>().assignCategory(
                                    app.packageName,
                                    categoryName,
                                  );
                            },
                            onAddNewCategory: (newCategoryName) {
                              context.read<CategorizationCubit>().addCategory(newCategoryName);
                              context.read<CategorizationCubit>().assignCategory(
                                    app.packageName,
                                    newCategoryName,
                                  );
                            },
                          );
                        },
                      ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color(0xFFD4AF98),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterRow(List dynamicCategories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // "All" Filter
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          
          // "Uncategorized" Filter
          _buildFilterChip('Uncategorized', 'Uncategorized'),
          const SizedBox(width: 8),

          // Individual Category Filters
          ...dynamicCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildFilterChip(cat.name, cat.name),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedCategoryFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategoryFilter = value;
        });
      },
      selectedColor: const Color(0xFFD4AF98).withOpacity(0.3),
      checkmarkColor: const Color(0xFFD4AF98),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFD4AF98) : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No apps found matching "$_searchQuery"',
            style: const TextStyle(color: Colors.black38),
          ),
        ],
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
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CategorizationCubit>().addCategory(controller.text);
                Navigator.pop(innerContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF98)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}