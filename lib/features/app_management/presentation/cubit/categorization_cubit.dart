import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import '../../domain/entities/installed_app_entity.dart';
import '../../domain/entities/app_category_entity.dart';
import 'categorization_state.dart';

class CategorizationCubit extends Cubit<CategorizationState> {
  final CategorizationRepository repository;

  CategorizationCubit(this.repository) : super(const CategorizationState());

  /// Loads apps and categories. 
  /// Set [forceRefresh] to true to bypass cache and scan the OS again.
  Future<void> loadData({bool forceRefresh = false}) async {
    emit(state.copyWith(status: CategorizationStatus.loading));
    try {
      final results = await Future.wait([
        repository.getInstalledApps(forceRefresh: forceRefresh),
        repository.getCategories(),
      ]);

      emit(state.copyWith(
        status: CategorizationStatus.success,
        apps: results[0] as List<InstalledApp>, 
        categories: results[1] as List<AppCategoryEntity>,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategorizationStatus.failure,
        errorMessage: 'Failed to load data: ${e.toString()}',
      ));
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final newCategory = AppCategoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      );
      // FIX: Ensure this line passes the entity, not just the name string
      // The error you saw happens if this was 'repository.addCategory(name)'
      await repository.addCategory(newCategory);
      
      await loadData(forceRefresh: false);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add category'));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await repository.deleteCategory(id);
      await loadData(forceRefresh: false);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete category'));
    }
  }

  Future<void> assignCategory(String packageName, String categoryName) async {
    try {
      await repository.assignCategory(packageName, categoryName);
      
      final updatedApps = state.apps.map((app) {
        if (app.packageName == packageName) {
          return app.copyWith(assignedCategoryName: categoryName);
        }
        return app;
      }).toList();
      
      emit(state.copyWith(apps: updatedApps));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to assign category'));
    }
  }
}