/// The Domain Entity representing an installed application on the user's device.
/// It includes the currently assigned category name, which is retrieved from storage.
class InstalledApp {
  final String packageName;
  final String name;
  final String? assignedCategoryName; // Null if not categorized

  InstalledApp({
    required this.packageName, 
    required this.name, 
    this.assignedCategoryName
  });
}