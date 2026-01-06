import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/theme/app_visuals.dart';
import '../../domain/entities/entities.dart';
import '../cubit/categorization_cubit.dart';
import '../cubit/categorization_state.dart';
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
  String? _selectedCategoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<CategorizationCubit, CategorizationState>(
          builder: (context, state) {
            if (state.status == CategorizationStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final filteredApps = state.apps.where((app) {
              final matchesSearch = app.name.toLowerCase().contains(_searchQuery.toLowerCase());
              bool matchesCategory = true;
              if (_selectedCategoryFilter != null) {
                matchesCategory = (app.assignedCategoryName ?? 'Neutral') == _selectedCategoryFilter;
              }
              return matchesSearch && matchesCategory;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text('Categorization', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: AppShapes.cardBorder, borderSide: BorderSide.none),
                    ),
                  ),
                ),
                _buildFilterRow(state.categories),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      return AppAssignmentTile(
                        app: app,
                        availableCategories: state.categories,
                        onAssignCategory: (name) => context.read<CategorizationCubit>().assignCategory(app.packageName, name),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterRow(List<AppCategoryEntity> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildFilterChip(cat.name, cat.name),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedCategoryFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedCategoryFilter = value),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppShapes.buttonRadius)),
    );
  }
}