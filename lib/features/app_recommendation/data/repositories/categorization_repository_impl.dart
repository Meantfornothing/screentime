import '../../domain/repositories/categorization_repository.dart';
import '../../domain/entities/app_category_entity.dart';
import '../../domain/entities/installed_app.dart';

class CategorizationRepositoryImpl implements CategorizationRepository {
  // Simulating a local database state
  final List<AppCategoryEntity> _mockCategories = [
    AppCategoryEntity(id: '1', name: 'Entertainment'),
    AppCategoryEntity(id: '2', name: 'Productivity'),
    AppCategoryEntity(id: '3', name: 'Neutral'),
  ];

  final List<InstalledApp> _mockApps = [
    InstalledApp(packageName: 'com.social.app1', name: 'Social App', assignedCategoryName: 'Relaxation'),
    InstalledApp(packageName: 'com.game.app2', name: 'Game Zone', assignedCategoryName: 'Entertainment'),
    InstalledApp(packageName: 'com.work.app3', name: 'Work Chat', assignedCategoryName: 'Productivity'),
    InstalledApp(packageName: 'com.utility.app4', name: 'Utility Tool'),
  ];

  @override
  Future<List<AppCategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockCategories);
  }

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockApps);
  }

  @override
  Future<void> addCategory(String name) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    _mockCategories.add(AppCategoryEntity(id: newId, name: name));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockCategories.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> assignCategory(String packageName, String categoryName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockApps.indexWhere((app) => app.packageName == packageName);
    if (index != -1) {
      _mockApps[index] = InstalledApp(
        packageName: _mockApps[index].packageName,
        name: _mockApps[index].name,
        assignedCategoryName: categoryName,
      );
    }
  }
}