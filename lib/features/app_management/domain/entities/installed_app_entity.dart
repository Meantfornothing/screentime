import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class InstalledApp extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? assignedCategoryName; 

  // New: Tracks usage duration. Not persisted (@HiveField omitted).
  final Duration usageDuration;

  InstalledApp({
    required this.packageName, 
    required this.name, 
    this.assignedCategoryName,
    this.usageDuration = Duration.zero,
  });
  
  // Helper for immutability
  InstalledApp copyWith({
    String? packageName,
    String? name,
    String? assignedCategoryName,
    Duration? usageDuration,
  }) {
    return InstalledApp(
      packageName: packageName ?? this.packageName,
      name: name ?? this.name,
      assignedCategoryName: assignedCategoryName ?? this.assignedCategoryName,
      usageDuration: usageDuration ?? this.usageDuration,
    );
  }
}

class InstalledAppAdapter extends TypeAdapter<InstalledApp> {
  @override
  final int typeId = 1;

  @override
  InstalledApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstalledApp(
      packageName: fields[0] as String,
      name: fields[1] as String,
      assignedCategoryName: fields[2] as String?,
      usageDuration: Duration.zero, 
    );
  }

  @override
  void write(BinaryWriter writer, InstalledApp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.assignedCategoryName);
  }
}