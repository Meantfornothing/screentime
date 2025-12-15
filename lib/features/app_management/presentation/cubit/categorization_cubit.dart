import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/categorization_repository_interface.dart';
import 'categorization_state.dart';

class CategorizationCubit extends Cubit<CategorizationState> {
  final CategorizationRepository repository;

  CategorizationCubit(this.repository) : super(const CategorizationState());

  Future<void> loadData() async {
    emit(state.copyWith(status: CategorizationStatus.loading));
    try {
      final results = await Future.wait([
        repository.getInstalledApps(),
        repository.getCategories(),
      ]);

      emit(state.copyWith(
        status: CategorizationStatus.success,
        apps: results[0] as dynamic,
        categories: results[1] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategorizationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addCategory(String name) async {
    try {
      await repository.addCategory(name);
      // Reload to get updated list
      final newCategories = await repository.getCategories();
      emit(state.copyWith(categories: newCategories));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await repository.deleteCategory(id);
      final newCategories = await repository.getCategories();
      emit(state.copyWith(categories: newCategories));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> assignCategory(String packageName, String categoryName) async {
    try {
      await repository.assignCategory(packageName, categoryName);
      final newApps = await repository.getInstalledApps();
      emit(state.copyWith(apps: newApps));
    } catch (e) {
      // Handle error
    }
  }
}